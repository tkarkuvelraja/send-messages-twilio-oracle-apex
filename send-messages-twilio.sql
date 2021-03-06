-- Procedure to send messages (send_message_twilio)
-- Note: Twilio API is used to send messages
--
  
CREATE OR REPLACE
PROCEDURE send_message_twilio(
    p_to_mobile_code   IN NUMBER,
    p_to_mobile_number IN NUMBER,
    p_message_body     IN VARCHAR2,
    x_return_message out VARCHAR2,
    x_return_status out VARCHAR2)
AS
  l_base_url                VARCHAR2(240) := 'https://api.twilio.com/2010-04-01/Accounts/';
  l_url_path_prefix         VARCHAR2(240) := '{{TWILIO_ACCOUNT_SID}}/Messages.json';
  l_twilio_sent_message_url VARCHAR2(240);
  l_twilio_phone_number     VARCHAR2(240) := '<<Your Twilio Account Phone Number>>';                       -- From Mobile Number
  l_twilio_account_sid      VARCHAR2(240) := '<<Your Twilio Account SID>>'; -- Username
  l_twilio_auth_token       VARCHAR2(240) := '<<Your Twilio Account Auth Token>>';   -- Password
  l_response CLOB;
BEGIN
  x_return_status                             := 'S';
  x_return_message                            := 'SMS Sent Successfully!';
  
  apex_web_service.g_request_headers(1).NAME  := q'#User-Agent#';
  apex_web_service.g_request_headers(1).VALUE := q'#Oracle Application Express / REST Client Assistant#';
  apex_web_service.g_request_headers(2).NAME  := 'Content-Type';
  apex_web_service.g_request_headers(2).VALUE := 'application/x-www-form-urlencoded';

  l_twilio_sent_message_url                   := l_base_url || REPLACE (l_url_path_prefix, '{{TWILIO_ACCOUNT_SID}}', l_twilio_account_sid);

  dbms_output.put_line ('Twilio Sent Message URL:' || l_twilio_sent_message_url);
  
  l_response := apex_web_service.make_rest_request(p_url => l_twilio_sent_message_url , 
                                     p_http_method => 'POST', 
                                     p_username => l_twilio_account_sid, 
                                     p_password => l_twilio_auth_token, 
                                     p_parm_name => apex_util.string_to_table('To:From:Body'), 
                                     p_parm_value => apex_util.string_to_table('+'||REPLACE(p_to_mobile_code,'+','')||' '||p_to_mobile_number||':'||l_twilio_phone_number||':'||p_message_body||''));

  dbms_output.put_line ('Twilio Sent Message Response:' || l_response);

  IF apex_web_service.g_status_code NOT BETWEEN 200 AND 299 THEN
    x_return_status  := 'E';
    x_return_message := 'HTTP-'|| apex_web_service.g_status_code;
  END IF;
exception
WHEN others THEN
  x_return_status  := 'E';
  x_return_message := 'Unexpected Error: '||sqlcode||' ['||sqlerrm||']';
END send_message_twilio;
/

-- Anonymous block to call send_message_twilio
-- Note: It will be called from Oracle APEX screen
--

DECLARE
  p_to_mobile_code   NUMBER;
  p_to_mobile_number NUMBER;
  p_message_body     VARCHAR2(200);
  x_return_message   VARCHAR2(200);
  x_return_status    VARCHAR2(200);
BEGIN
  p_to_mobile_code   := :p1_mobile_code;
  p_to_mobile_number := :p1_mobile_number;
  p_message_body     := :p1_message_body;
  
  send_message_twilio( p_to_mobile_code => p_to_mobile_code, 
                       p_to_mobile_number => p_to_mobile_number, 
                       p_message_body => p_message_body, 
                       x_return_message => x_return_message,
                       x_return_status => x_return_status 
                      );
  
  DBMS_OUTPUT.PUT_LINE('X_RETURN_MESSAGE = ' || X_RETURN_MESSAGE);
  
  DBMS_OUTPUT.PUT_LINE('X_RETURN_STATUS = ' || X_RETURN_STATUS);
END;
/
