mod components;

use stylist::{style,yew::styled_component};
use yew::prelude::*;

use crate::components::pixel_rain::PixelRain;

#[styled_component]
pub fn App() -> Html
{
	let center = style!(r#"
			position: absolute;
			margin: auto;
			display: block;
			bottom: 0px;
			top: 0px;
			left: 50%;
			transform: translate(-50%, 0);
		"#).unwrap();
	html!
	{
		<>
			<div class={center}>
				<PixelRain />
			</div>
		</>
	}
}
