import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
void main(){
  runApp(MyApp(title: 'http'));
}
class MyApp extends StatelessWidget {
  final String title;
  MyApp({Key key, this.title}) : super(key: key);
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primaryColor: Colors.cyan[400],
        buttonColor: Colors.cyan[400],
      ),
      home: Home(),
    );
  }
}
class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}
class HomeState extends State<Home> {
  int _currentIndex = 0;
  List<Widget> _body = [
    Individual(),
    Client(),
    Streamed(),
  ];
  void _navigate(i){
    setState(() {
      _currentIndex = i;
    });
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('http'),
        ),
      body: _body.elementAt(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.send),
            title: Text('Individual POST'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.share),
            title: Text('Client connection'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user),
            title: Text('Streamed'),
          ),
        ],
        currentIndex: _currentIndex,
        onTap: _navigate,
      ),
    );
  }
}
class Individual extends StatefulWidget {
  @override
  IndividualState createState() => IndividualState();
}
class IndividualState extends State<Individual> {
  dynamic _status = '';
  dynamic _body = '';
  void _httpPost() async{
    var _response = await http.post('http://www.stealmylogin.com/demo.html', body: {'username': '123', 'password': '456'});
    setState(() {
      _status = _response.statusCode;
      _body = _response.body;
    });
  }
  void _httpRead1() async{
    _status = '';
    String _response;
    try {
      _response = await http.read('https://example.com/foobar.txt');
      _body = _response;
    } on Exception catch(exception, stackTrace) { 
      _status = exception;
      _body = 'Stack trace:\n$stackTrace';
    } finally {
      setState(() {
        _body;
      }); 
    }
  }
  void _httpRead2() async{
    _status = '';
    try {
      _body = await http.read('https://raw.githubusercontent.com/sdias/win-10-virtual-desktop-enhancer/master/settings.ini');
    } on Exception catch(exception, stackTrace) {
      _status = exception;
      _body = 'Stack trace: $stackTrace';
    } finally {
      setState(() {
        _status; 
        _body;
      }); 
    }
  }
  @override
  Widget build(BuildContext context){
    return Column(
      children: <Widget>[
        Center(
          child: Column(
            children: <Widget>[
              RaisedButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.http),
                      Text(' POST',),
                    ],
                  ),
                  onPressed: _httpPost,
                  elevation: 20.0, 
                  shape: RoundedRectangleBorder( 
                    borderRadius: BorderRadius.circular(20.0),
                  ),
              ),
              RaisedButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.http),
                      Text(' Read non-existent link',),
                    ],
                ),
                  onPressed: _httpRead1,
              ),
              RaisedButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.http),
                      Text(' Read existent link',),
                    ],
                  ),
                  onPressed: _httpRead2,
              ),
            ],
          ),
        ),
        _status != '' ? Expanded(
          child: Center(
            child: Text(
              '$_status',
            ),
          ),
        ) : Container(), 
        Expanded(
          child: SingleChildScrollView(
            child: Center(
              child: Text(
                '$_body',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
class Client extends StatefulWidget {
  @override
  ClientState createState() => ClientState();
}
class ClientState extends State<Client> {
  dynamic _status = '';
  dynamic _body = '';
  dynamic _headers = '';
  var client;
  void _httpOpen(){
    client = http.Client();
  }
  void _httpPostGet() async{
    if(client != null){
    try {
      var uriResponse = await client.post(
        'http://www.stealmylogin.com/demo.html',
        body: {'username': '123', 'password': '456'}
      );
      _body = await client.get('http://www.stealmylogin.com/demo.html', headers: {'user-agent': 'Fiddler'}); 
      setState(() {
        _status = uriResponse.statusCode;
        _body = _body.body;
        _headers = uriResponse.headers;
      });
    } catch(e, sT) {
      setState(() {
        _status = e;
        _body = 'Stack trace:\n$sT';  
      });
    }
    }
    else{
      setState(() {
        _status = 'No Client!';
      });
    }
  }
  void _httpClose(){
    if(client != null){
      client.close();
    }
    else{
      setState(() {
        _status = 'No Client!';
      });
    }
  }
  @override
  Widget build(BuildContext context){
    return ListView(
      addAutomaticKeepAlives: false, 
      cacheExtent: 100.0, 
      children: <Widget>[
        Center(
          child: RaisedButton.icon( 
              icon: Icon(Icons.http),
              label: Text('Open Client'),
              onPressed: _httpOpen,
            ),
        ),
        Center(
          child: RaisedButton.icon(
              icon: Icon(Icons.http),
              label: Text('Client POST&GET'),
              onPressed: _httpPostGet,
            ),
        ),
        Center(
          child: RaisedButton.icon(
              icon: Icon(Icons.http),
              label: Text('Close client'),
              onPressed: _httpClose,
            ),
        ),
          Center(
            child: Text(
              '$_status'
            ),
          ),
          Center(
            child: Text(
              '$_body'
            ),
          ),
          Center(
            child: Text(
              '$_headers'
            ),
          ),
      ],
    );
  }
}
class Streamed extends StatefulWidget {
  @override
  StreamedState createState() => StreamedState();
}
class StreamedState extends State<Streamed> {
  dynamic _status = '';
  dynamic _body = '';
  dynamic _headers = '';
  String _reason = '';
  http.Client client = http.Client();
  String userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.121 Safari/537.36';
  UserAgentClient userAgentClient;
  http.StreamedRequest streamedRequest;
  void _httpStreamed(){
    userAgentClient = UserAgentClient(userAgent, client);
    streamedRequest = http.StreamedRequest('POST', Uri(scheme: 'http', path: '/posts/', host: 'jsonplaceholder.typicode.com'));
    streamedRequest.sink.add(utf8.encode('{"username":"123","password":"456"}')); 
    setState(() {
      _status = streamedRequest.url;
      _body = '';
      _headers = '';
      _reason = '';
    });
  }
  void _httpSink(){
    if (streamedRequest != null){
      try {
      streamedRequest.sink.add(utf8.encode('{"username":"123","password":"456"}'));
      setState(() {
        _status = streamedRequest.url;
        _body = '';
        _headers = '';
        _reason = '';
      });
      } catch (e, sT) {
        setState(() {
          _status = e;
          _body = 'Stack trace:\n$sT';
          _headers = '';
          _reason = '';
        });
      }
    }
  }
  void _httpSend() async{
    if (userAgentClient != null) {
      http.StreamedResponse streamedResponse;
      try {
      streamedResponse = await userAgentClient.send(streamedRequest);
      streamedResponse.stream.listen(
        (value) async{
            _body = http.ByteStream.fromBytes(value);
            _body = await _body.bytesToString();
        },
        onError: (e, sT) {
          SnackBar sBar = SnackBar(content: Text('$e\n$sT',));
          Scaffold.of(context).showSnackBar(sBar);
        },
        onDone: () {
          SnackBar sBar = SnackBar(content: Text('Done lol'),);
          Scaffold.of(context).showSnackBar(sBar);
        },
      );
      } catch (e, sT) {
        setState(() {
          _status = e;
          _body = 'Stack trace:\n$sT';
          _headers = '';
          _reason = '';
        });
      }
      setState(() {
        _body;
        _status = streamedResponse.statusCode;
        _headers = streamedResponse.headers;
        _reason = streamedResponse.reasonPhrase;
      });
    }
  }
  void _httpClose(){
    if (streamedRequest != null){
      streamedRequest.sink.close();
    }
  }
  @override
  Widget build(BuildContext context){
    return ListView(
      children: <Widget>[
        Center(
          child: RaisedButton.icon(
              icon: Icon(Icons.http),
              label: Text('Make a POST streamed request'),
              onPressed: _httpStreamed,
            ),
        ),
        Center(
          child: RaisedButton.icon(
              icon: Icon(Icons.http),
              label: Text('Add more data to the sink'),
              onPressed: _httpSink,
            ),
        ),
        Center(
          child: RaisedButton.icon(
              icon: Icon(Icons.http),
              label: Text('Send the request'),
              onPressed: _httpSend,
            ),
        ),
        Center(
          child: RaisedButton.icon(
              icon: Icon(Icons.http),
              label: Text('Close the sink'),
              onPressed: _httpClose,
            ),
        ),
          Center(
            child: Text(
              '$_status'
            ),
          ),
          Center(
            child: Text(
              '$_body'
            ),
          ),
          Center(
            child: Text(
              '$_headers'
            ),
          ),
          Center(
            child: Text(
              '$_reason'
            ),
          ),
      ],
    );
  }
}
class UserAgentClient extends http.BaseClient {
  final String userAgent;
  final http.Client client;
  UserAgentClient(this.userAgent, this.client);
  Future<http.StreamedResponse> send(http.BaseRequest request){
    request.headers['user-agent'] = userAgent; 
    return client.send(request);
  }
}
