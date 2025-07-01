import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:focalix/secrets.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ImageChat extends StatefulWidget {
  const ImageChat({super.key});

  @override
  State<ImageChat> createState() => _ImageChatState();
}

class _ImageChatState extends State<ImageChat> {

  XFile? pickedImage;
  String mytext = '';
  bool scanning=false;

  TextEditingController prompt=TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  final apiUrl='https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$NewsAPIKey';

  final header={
    'Content-Type': 'application/json',
  };


  getImage(ImageSource ourSource) async {
    XFile? result = await _imagePicker.pickImage(source: ourSource);

    if (result != null) {
      setState(() {
        pickedImage = result;
      });
    }
  }

  getdata(image,promptValue)async{

    setState(() {
      scanning=true;
      mytext='';
    });

  try{
    
  List<int> imageBytes = File(image.path).readAsBytesSync();
  String base64File = base64.encode(imageBytes);
  
  final data={
    "contents": [
    {
      "parts": [

        {"text":promptValue},
        
        {
          "inlineData": {
            "mimeType": "image/jpeg",
            "data": base64File,
          }
        }
      ]
    }
  ],
  };

  await http.post(Uri.parse(apiUrl),headers: header,body: jsonEncode(data)).then((response){

    if(response.statusCode==200){

      var result=jsonDecode(response.body);
      mytext=result['candidates'][0]['content']['parts'][0]['text'];
      
    }else{
      mytext='Response status : ${response.statusCode}';
    }

  }).catchError((error){
    print('Error occored $error');
  });
  }catch(e){
    print('Error occured $e');
  }

  scanning=false;
  
  setState(() {});

  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.black,
      appBar: AppBar(
        
        title: Center(child: Text('         F O C A L I X',style: TextStyle(color: Colors.grey,fontSize: 30,fontWeight: FontWeight.w400),)),
        
        backgroundColor: Colors.black,
        
        actions: [
          IconButton(onPressed: (){

          getImage(ImageSource.gallery);

        }, icon: Icon(Icons.attachment_rounded,color: Colors.cyanAccent,)),SizedBox(width: 5,)],
        ),    
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Container(
                    height: 155,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(image: AssetImage("assets/images/image.png"),)
                    ),
                    
                  ), SizedBox(height: 20,),

            pickedImage == null
                ? Container(
                  height: 300,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(40.0),
                  border: Border.all(color: Colors.cyanAccent,width: 2.0,),),
                  
                  child: Center(child: Icon(Icons.image_rounded),))
                :
            SizedBox(height:300,child: Center(child: Image.file(File(pickedImage!.path),height: 400,))),
            

            SizedBox(height: 20),
            
            TextField(
              controller: prompt,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.cyanAccent,width: 2.0,),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.cyanAccent,width: 2.0,),
                ),
                prefixIcon: Icon(
                  Icons.create_outlined,
                  color: Colors.cyanAccent,
                ),
                hintText: ' your prompt ',hintStyle: TextStyle(fontSize: 18)
              ),
            ),
            SizedBox(height: 20,),

            ElevatedButton.icon(
              onPressed: (){
                  getdata(pickedImage,prompt.text);
              }, 
              icon: Icon(Icons.auto_awesome_outlined,color: Colors.cyanAccent,size: 28,), 
              label: Padding(
                padding: const EdgeInsets.all(10),
                child: Text('Generate Answer',style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),),
              ),
               style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 50, 50, 50),),
              ),

          SizedBox(height: 30),

          scanning?
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Center(child: SpinKitThreeBounce(color: Colors.black,size: 20,)),
          ):
          Text(mytext,textAlign: TextAlign.center,style: TextStyle(fontSize: 20)),
        
        
          ],
        ),
      ),

    );

  }
}