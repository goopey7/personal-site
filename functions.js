$(document).ready(function()
{

    setInterval ('cursorAnimation()', 600);
    
    var text = 'whois sam.collier<br><br>Sam Collier, Born on the 16th of September 2002.'+
	'<br><br><b>Contact</b>: &nbsp; &nbsp; <a href="https://www.instagram.com/samc0llier/">Instagram</a>'+
	' &nbsp; <a href="mailto:sam@samcollier.tech">sam@samcollier.tech</a>'+
	'<br><br><a href="https://github.com/goopey7"><b>You can find my code on GitHub</b></a>'+
	'<br><br><a href="https://dnekos.itch.io/lucifur"><b>Checkout the game I made with my team for the AGDS Halloween Game Jam!</b></a>'+
	'<br><br>#';
    type(text);
});

function type(text, new_caption_length)
{
    captionLength = new_caption_length || 0;

    $('#caption').html(text.substr(0, captionLength++));
    if(captionLength < text.length+1)
	{
        setTimeout(function()
		{
            type(text, captionLength);
        }, 1);
    }
}

function erase()
{
    caption = $('#caption').html();
    captionLength = caption.length;
    if(captionLength > 0){
        $('#caption').html(caption.substr(0, captionLength-1));
        setTimeout(function(){
            erase();
        }, 1);
    }
}

function cursorAnimation()
{
    $('#cursor').animate({
        opacity: 0
    }, 'fast', 'swing').animate({
        opacity: 1
    }, 'fast', 'swing');
}
