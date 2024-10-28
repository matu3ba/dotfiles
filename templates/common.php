// https://stackoverflow.com/questions/9289269/most-reliable-safe-method-of-preventing-race-conditions-in-php
// SHENNANIGAN php creates multiple instances on multiple parallel incoming
// user requests, which can race against another without recommended or native
// way to prevent this race conditions
// * the typical suggested solution is to use form keys in $_SESSION,
// which also protects your against CSRF attacks
// * running in (not session or source ip based) load balancing scenario
// involving multiple hosts it becomes more complicated as shown in
// http://thwartedefforts.org/2006/11/11/race-conditions-with-ajax-and-php-sessions/
//
// debug printing
// $_POST = json_decode(file_get_contents('php://input'), true);
// error_log( print_r( $_POST, true ) . "\n" ); // debug json

// get html headers
$headers =  getallheaders();
foreach($headers as $key=>$val){
  error_log $key . ': ' . $val . '\n';
}