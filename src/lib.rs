mod components;

use yew::prelude::*;

use crate::components::pixel_rain::PixelRain;

#[function_component]
pub fn App() -> Html
{
    html!
    {
        <>
            <PixelRain />
        </>
    }
}
