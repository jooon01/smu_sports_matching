import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class LoginWidget extends StatelessWidget {
  LoginWidget({Key? key}) : super(key: key);

  // GoogleSignIn 객체 선언
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Google 로그인 함수
  Future<bool> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      await firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);
      showSnackBar(context, 'Google 로그인 성공');
      return true; // 로그인 성공
    } catch (e) {
      return false; // 로그인 실패
    }
  }

  // Kakao 로그인 함수
  Future<void> signInWithKakao(BuildContext context) async {
    try {
      // 카카오톡 설치 여부 확인 후 로그인 시도
      var provider = OAuthProvider("oidc.sportsmatching");
      OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
      var credential = provider.credential(
        idToken: token.idToken,
        accessToken: token.accessToken,
      );
      // Firebase 로그인
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // 로그인 성공 후, userId 가져오기
      final userId = userCredential.user?.uid;
      print('카카오 로그인 성공! Firebase userId: $userId');

      // 로그인 성공 후, Snackbar로 로그인 성공 메시지 표시
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카카오 로그인 성공')),
        );
      });
    } catch (error) {
      // 로그인 실패 시 Snackbar로 오류 메시지 표시
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카카오 로그인 실패')),
        );
      });
    }
  }
  // 공통 SnackBar 메시지 출력 함수
  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/logo.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 300),
              LoginButton(
                text: "Google Login",
                color: Colors.blue,
                onPressed: () => _handleLogin(context, signInWithGoogle),
              ),
              LoginButton(
                text: "Kakao Login",
                color: Colors.amber,
                onPressed: () => signInWithKakao(context),
                //=> _handleLogin(context, signInWithKakao),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 로그인 처리 후 결과에 따라 화면을 반환하는 함수
  void _handleLogin(BuildContext context, Future<bool> Function(BuildContext) loginFunction) async {
    bool success = await loginFunction(context);

    if (success) {
      // 로그인 성공 후 '/root' 경로로 이동
      Navigator.pushReplacementNamed(context, '/root');
    }
  }
}

// 공통 버튼 위젯
class LoginButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const LoginButton({
    Key? key,
    required this.text,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // 원하는 borderRadius 값 설정
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
