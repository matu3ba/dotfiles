// debug printing
// $_POST = json_decode(file_get_contents('php://input'), true);
// error_log( print_r( $_POST, true ) . "\n" ); // debug json

// get html headers
$headers =  getallheaders();
foreach($headers as $key=>$val){
  error_log $key . ': ' . $val . '\n';
}
