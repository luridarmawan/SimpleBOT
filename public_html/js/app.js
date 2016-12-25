
url = '/ai/?_DEBUG=1&t=';


jQuery(document).ready(function() {

  function InsertChatBox( Sender, Message){
    Message = Message.replace(/\n/g, "<br>");
    html = '<li class="left clearfix">';
    html = html + '<span class="chat-img pull-left"><img src="http://placehold.it/50/55C1E7/fff&text=BOT" class="img-circle" /></span>';
    html = html + '<div class="chat-body clearfix">';
    html = html + '<div class="header">';
    html = html + '<strong class="primary-font">BOT</strong> <small class="pull-right text-muted">';
    html = html + '<span class="glyphicon glyphicon-time"></span>... ago</small>';
    html = html + '</div>';
    html = html + '<p>';
    html = html + Message;
    html = html + '</p>';
    html = html + '</div>';
    html = html + '';

    html = html + '</li>';
    $( '#chat').append( html);
    $('#panel-body').animate({ scrollTop: 9999 }, 'slow');
  }

  function InsertMyChatBox( Message){
    html = '<li class="right clearfix"><span class="chat-img pull-right">';
    html = html + '<img src="http://placehold.it/50/FA6F57/fff&text=ME" class="img-circle" />';
    html = html + '</span>';
    html = html + '<div class="chat-body clearfix">';
    html = html + '<div class="header">';
    html = html + '<small class=" text-muted"><span class="glyphicon glyphicon-time"></span>...</small>';
    html = html + '<strong class="pull-right primary-font">Me</strong>';
    html = html + '</div>';
    html = html + '<p class="pull-right">';
    html = html + Message;
    html = html + '</p>';
    html = html + '</div>';
    html = html + '';

    html = html + '</li>';
    $( '#chat').append( html);
    $('#panel-body').animate({ scrollTop: 9999 }, 'slow');
  }

  function SendMessage( Recipient, Message){
    InsertMyChatBox( Message);

    json = '{"message":{"message_id":0,"text":"'+Message+'","chat":{"id":0}}}';
    
    var timestamp = new Date().getTime();
    var posting = jQuery.post(url+timestamp, json);
    
    posting.done(function(data) {
      response_text = data.response.text;
      if ( Array.isArray( response_text)){
        $( '#log').text(  JSON.stringify( data, null, 4) );
        for (var i = 0, len = response_text.length; i < len; i++) {
          InsertChatBox( 'Dia', response_text[i]);
        }
      }else{
        InsertChatBox( 'Dia', response_text);
      }
    });

  }

  $( "input#text" ).on( "keydown", function(event) {
    if(event.which == 13)
      $('#btnChat').click();
  });

  $('#btnChat').click(function() {
    $( '#log').text('');
    Message = $( 'input#text').val();
    if ( Message == '')
      Exit;

    SendMessage( '', Message);

    //$( 'input#text').val('');
    $( 'input#text').focus();
  });







  $( '#panel-body').height( $( document ).height()-150);
  $( '#LogContainer').height( $( document ).height()-50);
  $( '#log').css( 'height', '100%');
  


  $( 'input#text').focus();
}); 


