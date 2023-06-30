use yew::prelude::*;

pub enum Msg
{
}

pub struct PixelRain
{
    canvas: NodeRef
}

impl Component for PixelRain
{
    type Message = Msg;
    type Properties = ();

    fn create(ctx: &Context<Self>) -> Self
    {
        Self
        {
            canvas: NodeRef::default()
        }
    }

    fn update(&mut self, ctx: &Context<Self>, msg: Self::Message) -> bool
    {
        true
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
