$(document).ready(function()
{

    setInterval ('cursorAnimation()', 600);
    
    var text = 'whois sam.collier<br><br>Sam Collier, Passionate Game Developer and Entrepreneur'+
	'<br><br><b>Contact</b>: &nbsp; &nbsp; <a href="https://www.linkedin.com/in/samuel-collier/">LinkedIn</a>'+
	' &nbsp; <a href="mailto:sam@samcollier.tech">sam@samcollier.tech</a>'+
	'<br><br><a href="https://github.com/goopey7"><b>You can find my code on GitHub</b></a>'+
	'<br><br><a href="https://triple7studios.itch.io/left-upon-read-first-playable"><b>Check out my team\'s first playable!</b></a>'+
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
