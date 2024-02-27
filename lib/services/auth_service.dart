 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fleet_map_tracker/helper/helper.dart';
import 'package:fleet_map_tracker/services/database_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
 
enum UserCredentialConstant {  user, admin, error } 

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  Future<bool> loginWithUserNameandPassword(
      String email, String password) async {
    try {
      // ignore: unused_local_variable
      User user = (await firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user!;
      // if (user.uid == '0UU2JGNDeDe0UtQfm556QcSl2Y02') {
      //   return UserCredentialConstant.admin;
      // } else {
        return true;
      // }
    } on FirebaseAuthException {
      return false;
    }
  }

  //////////////////////////////////////register//////////////////////
  Future registerUserWithEmailandPassword(
      String fullName, String email, String password ,String profile) async {
    try {
      User user = (await firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user!;

      // call our database service to update the user data.
      await DatabaseService(uid: user.uid).savingUserData(fullName, email, profile);
      print('Registering');
      return true;
    } on FirebaseAuthException catch (e) {
      print('Registering error');
      return e.message;
    }
  }

  Future signOut() async {
    try {
      await HelperFunctions.saveUserLoggedInStatus(false);
      await HelperFunctions.saveUserEmailSF("");
      await HelperFunctions.saveUserNameSF("");
      firebaseAuth.signOut();
    } catch (e) {
      return e;
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) throw Null;
      // ignore: unnecessary_nullable_for_final_variable_declarations
      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (error) {
      throw Null;
    }
  }
  

}
