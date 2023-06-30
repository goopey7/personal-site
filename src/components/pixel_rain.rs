use gloo::console::error;
use rand::{thread_rng, Rng};
use wasm_bindgen::{JsCast, JsValue, prelude::Closure};
use wasm_bindgen_futures::JsFuture;
use web_sys::{RequestInit, window, Request, Response, Blob, HtmlCanvasElement, ImageBitmap, CanvasRenderingContext2d};
use yew::prelude::*;

pub enum Msg
{
	FetchImageOk(ImageBitmap),
	FetchImageErr(FetchImageError),
	Render,
}

pub struct PixelRain
{
	canvas: NodeRef,
	particles: Vec<Particle>,
	callback: Closure<dyn FnMut()>,
}

impl Component for PixelRain
{
	type Message = Msg;
	type Properties = ();

	fn create(ctx: &Context<Self>) -> Self
	{
		ctx.link().send_future(async
			{
				match fetch_image("img/bass.png").await
				{
					Ok(image) => Msg::FetchImageOk(image),
					Err(err) => Msg::FetchImageErr(err)
				}
			});
		let ctx_clone = ctx.link().clone();
		let callback = Closure::wrap(Box::new(move ||
			{
				ctx_clone.send_message(Msg::Render);
			}) as Box<dyn FnMut()>);
		Self
		{
			canvas: NodeRef::default(),
			particles: Vec::new(),
			callback,
		}
	}

	fn update(&mut self, ctx: &Context<Self>, msg: Self::Message) -> bool
	{
		match msg
		{
			Msg::FetchImageOk(image) => 
			{
				let width = image.width();
				let height = image.height();
				let canvas: HtmlCanvasElement = self.canvas.cast().unwrap();
				canvas.set_width(width);
				canvas.set_height(height);
				self.particles = (0..10000).map(|_| {Particle::new(width, height)}).collect();
				ctx.link().send_message(Msg::Render);
				true
			},
			Msg::FetchImageErr(err) =>
			{
				error!(format!("Error fetching image: {:?}", err.error));
				true
			},
			Msg::Render =>
			{
				self.render();
				true
			},
		}
	}

	fn view(&self, ctx: &Context<Self>) -> Html
	{
		html!
		{
			<div>
				<canvas
					id="canvas"
					ref={self.canvas.clone()}
				/>
			</div>
		}
	}
}

impl PixelRain
{
	fn render(self: &mut Self)
	{
		let canvas: HtmlCanvasElement = self.canvas.cast().unwrap();
		let ctx: CanvasRenderingContext2d = canvas
			.get_context("2d")
			.unwrap()
			.unwrap()
			.unchecked_into();
		ctx.set_global_alpha(0.05);
		ctx.set_fill_style(&JsValue::from_str("black"));
		ctx.fill_rect(0.0, 0.0, canvas.width() as f64, canvas.height() as f64);
		ctx.set_global_alpha(0.2);
		self.particles.iter_mut().for_each(|particle|
			{
				particle.update();
				particle.render(&ctx);
			});
		window().unwrap()
			.request_animation_frame(
				self.callback.as_ref().unchecked_ref()
			).unwrap();
	}
}

struct Particle
{
	x: f64,
	y: f64,
	velocity: f64,
	size: f64,
	speed: f64,
	max_height: f64,
}

impl Particle
{
	fn new(width: u32, height: u32) -> Self
	{
		let mut rand = thread_rng();
		let x = rand.gen_range(0f64..width as f64);
		let y = 0 as f64;
		let velocity = rand.gen_range(0.5..10.0);
		let size = rand.gen_range(1.0..2.0);
		Self
		{
			x,
			y,
			velocity,
			size,
			speed: 0.0,
			max_height: height as f64,
		}
	}

	fn update(self: &mut Self)
	{
		let delta_y = self.velocity + self.speed;
		self.y += delta_y;
		if self.y > self.max_height
		{
			self.y = 0.0;
		}
	}

	fn render(self: &Self, ctx: &CanvasRenderingContext2d)
	{
		ctx.begin_path();
		ctx.set_fill_style(&JsValue::from_str("white"));
		ctx.arc(self.x, self.y, self.size, 0.0, 2.0 * std::f64::consts::PI).unwrap();
		ctx.fill();
	}
}

pub struct FetchImageError
{
	pub error: JsValue
}

impl From<JsValue> for FetchImageError
{
	fn from(error: JsValue) -> Self
	{
		Self { error }
	}
}

async fn fetch_image(file_path: &str) -> Result<ImageBitmap, FetchImageError>
{
	let mut opts = RequestInit::new();
	opts.method("GET");
	let request = Request::new_with_str_and_init(file_path, &opts)?;
	let window = window().unwrap();
	let resp_js_value = JsFuture::from(window.fetch_with_request(&request)).await?;
	let resp: Response = resp_js_value.dyn_into()?;
	let blob: Blob = JsFuture::from(resp.blob()?).await?.dyn_into()?;

	let image_bitmap_prom = window.create_image_bitmap_with_blob(&blob)?;
	Ok(JsFuture::from(image_bitmap_prom).await?.dyn_into()?)
}

