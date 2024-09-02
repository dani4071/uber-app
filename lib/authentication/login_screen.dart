import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uber_app_clone/authentication/signup_screen.dart';
import '../global/global_variables.dart';
import '../methods/common_methods.dart';
import '../pages/home_page.dart';
import '../widgets/loading_dialog.dart';


class loginScreen extends StatefulWidget {
  const loginScreen({super.key});

  @override
  State<loginScreen> createState() => _loginScreenState();
}



class _loginScreenState extends State<loginScreen>
{
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();



  checkIfNetworkIsAvailable()
  {
    cMethods.checkConnectivity(context);

    signInFormValidation();
  }

  signInFormValidation()
  {

    if(!emailTextEditingController.text.contains("@"))
    {
      cMethods.displaySnackBar("please write valid email.", context);
    }
    else if(passwordTextEditingController.text.trim().length < 5)
    {
      cMethods.displaySnackBar("your password must be atleast 6 or more characters.", context);
    }
    else
    {
      signInUser();
    }
  }

  signInUser() async
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => loadingDialog(messageText: "Allowing you to Login..."),
    );

    final User? userFirebase = (
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
        ).catchError((errorMsg)
        {
          Navigator.pop(context);
          cMethods.displaySnackBar(errorMsg.toString(), context);
        })
    ).user;

    if(!context.mounted) return;
    Navigator.pop(context);

    if(userFirebase != null)
    {
      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("users").child(userFirebase.uid);
      /// this await here is responsible for making the map load quickly and get your location
      await usersRef.once().then((snap)
      {
        if(snap.snapshot.value != null)
        {
          if((snap.snapshot.value as Map)["blockStatus"] == "no")
          {
            userName = (snap.snapshot.value as Map)["name"];
            userPhone = (snap.snapshot.value as Map)["phone"];
            Navigator.push(context, MaterialPageRoute(builder: (c)=> const homePage()));
          }
          else
          {
            FirebaseAuth.instance.signOut();
            cMethods.displaySnackBar("you are blocked. Contact admin: alizeb875@gmail.com", context);
          }
        }
        else
        {
          FirebaseAuth.instance.signOut();
          cMethods.displaySnackBar("your record do not exists as a User.", context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
      
                Image.asset(
                    "assets/logo.png"
                ),
      
                const Text(
                  "Login as a User",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      
                //text fields + button
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
      
                      TextField(
                        controller: emailTextEditingController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "User Email",
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
      
                      const SizedBox(height: 22,),
      
                      TextField(
                        controller: passwordTextEditingController,
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: "User Password",
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
      
                      const SizedBox(height: 32,),
      
                      ElevatedButton(
                        onPressed: ()
                        {
                          checkIfNetworkIsAvailable();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10)
                        ),
                        child: const Text(
                            "Login"
                        ),
                      ),
      
                    ],
                  ),
                ),
      
                const SizedBox(height: 12,),
      
                //textbutton
                TextButton(
                  onPressed: ()
                  {
                    Navigator.push(context, MaterialPageRoute(builder: (c)=> const signUpScreen()));
                  },
                  child: const Text(
                    "Don't have an Account? Register Here",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
      
              ],
            ),
          ),
        ),
      ),
    );
  }
}
