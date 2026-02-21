import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 현재 로그인된 Firebase 사용자
  User? get currentUser => _auth.currentUser;

  /// 인증 상태 스트림 (로그인/로그아웃 감지)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// 구글 소셜 로그인
  Future<UserModel?> signInWithGoogle() async {
    try {
      // 구글 로그인 다이얼로그 표시
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // 사용자가 취소함

      // 구글 인증 토큰 획득
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase 자격증명 생성
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase로 로그인
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user == null) return null;

      // Firestore에 사용자 정보 저장/업데이트
      return await _saveUserToFirestore(user);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('구글 로그인 중 오류가 발생했습니다: $e');
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  /// 현재 사용자 정보를 Firestore에서 가져오기
  Future<UserModel?> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Firestore에 사용자 정보 저장
  Future<UserModel> _saveUserToFirestore(User user) async {
    final docRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid);

    final doc = await docRef.get();
    final now = DateTime.now();

    if (!doc.exists) {
      // 신규 사용자 생성
      final newUser = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '정원사',
        photoUrl: user.photoURL,
        createdAt: now,
        updatedAt: now,
      );
      await docRef.set(newUser.toFirestore());
      return newUser;
    } else {
      // 기존 사용자 정보 업데이트 (이름, 사진만)
      await docRef.update({
        'displayName': user.displayName ?? '정원사',
        'photoUrl': user.photoURL,
        'updatedAt': Timestamp.fromDate(now),
      });
      return UserModel.fromFirestore(await docRef.get());
    }
  }

  /// Firebase 인증 예외 처리
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return Exception('이미 다른 방법으로 가입된 이메일입니다.');
      case 'invalid-credential':
        return Exception('인증 정보가 올바르지 않습니다.');
      case 'operation-not-allowed':
        return Exception('이 로그인 방법은 현재 사용할 수 없습니다.');
      case 'user-disabled':
        return Exception('비활성화된 계정입니다. 관리자에게 문의하세요.');
      case 'user-not-found':
        return Exception('사용자를 찾을 수 없습니다.');
      case 'network-request-failed':
        return Exception('네트워크 연결을 확인해주세요.');
      default:
        return Exception('로그인 오류: ${e.message}');
    }
  }
}
