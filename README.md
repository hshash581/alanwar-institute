# مع الأنوار - نظام إدارة المعهد

نظام إلكتروني شامل لإدارة المعهد التعليمي، يوفر إدارة الطلاب والمعلمين والمناهج والدفعات والتقارير.

## الميزات الرئيسية

### للإدارة
- إدارة حسابات الطلاب والمعلمين
- إنشاء حسابات مديرين آخرين
- إدارة الفصول والمادة والجدول
- نظام الدفعات والأقساط
- التقارير المالية والإدارية
- نشر الإعلانات

### للمعلمين
- عرض الحصص اليومية
- تسجيل الحضور والغياب
- عرض الإعلانات

### للطلاب
- عرض الجدول الدراسي
- متابعة الحضور والغياب
- متابعة الدفعات
- عرض المواد والواجبات
- عرض الإعلانات

## التقنيات

- **Flutter**: إطار عمل متعدد المنصات
- **Firebase**: Backend as a Service
  - Authentication
  - Cloud Firestore
  - Cloud Storage
- **Riverpod**: إدارة الحالة
- **Firestore Security Rules**: أمان قاعدة البيانات

## المتطلبات

- Flutter SDK 3.24.0+
- Dart SDK 3.5.0+
- Firebase Account
- Android Studio / VS Code

## التثبيت

1. استنساخ المستودع:
```bash
git clone https://github.com/username/alanwar_institute.git
cd alanwar_institute
```

2. تثبيت التبعيات:
```bash
flutter pub get
```

3. إعداد Firebase:
   - إنشاء مشروع Firebase
   - تحميل ملف `google-services.json`
   - وضعه في `android/app/`

4. تشغيل التطبيق:
```bash
flutter run
```

## بناء التطبيق

### Android APK:
```bash
flutter build apk --release
```

### Web:
```bash
flutter build web --release
```

## هيكل المشروع

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   └── app_strings.dart
│   ├── routing/
│   │   ├── auth_gate.dart
│   │   └── role_scaffold.dart
│   ├── services/
│   │   ├── admin_repository.dart
│   │   ├── auth_service.dart
│   │   ├── firebase_refs.dart
│   │   └── providers.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── widgets/
│       ├── common_cards.dart
│       └── state_widgets.dart
├── features/
│   ├── admin/
│   │   ├── admin_dashboard_screen.dart
│   │   ├── announcements/
│   │   ├── classes/
│   │   ├── payments/
│   │   ├── reports/
│   │   ├── schedule/
│   │   ├── students/
│   │   ├── subjects/
│   │   └── teachers/
│   ├── auth/
│   │   └── login_screen.dart
│   ├── student/
│   │   ├── student_home_screen.dart
│   │   ├── schedule_screen.dart
│   │   ├── attendance_screen.dart
│   │   ├── payments_screen.dart
│   │   ├── subjects_screen.dart
│   │   ├── assignments_screen.dart
│   │   ├── announcements_screen.dart
│   │   └── profile_screen.dart
│   └── teacher/
│       ├── teacher_home_screen.dart
│       └── class_attendance_screen.dart
├── models/
│   ├── user_model.dart
│   ├── student_model.dart
│   ├── teacher_model.dart
│   ├── records_model.dart
│   └── class_subject_schedule_model.dart
├── firebase_options.dart
└── main.dart
```

## الأمان

- Firebase Security Rules لحماية قاعدة البيانات
- التحقق من هوية المستخدم قبل الوصول للبيانات
- التحقق من صلاحيات المستخدم (مدير/معلم/طالب)
- تعطيل الحسابات غير النشطة

## النشر

### Android:
```bash
flutter build apk --release
# APK سيكون في: build/app/outputs/flutter-apk/app-release.apk
```

### Web:
```bash
flutter build web --release
# الملفات ستكون في: build/web/
```

### GitHub Pages:
يتم النشر تلقائياً عبر GitHub Actions عند الدفع إلى branch main.

## المسؤولية

هذا النظام مسؤول عن إدارة البيانات التعليمية والمالية للمعهد. يرجى التأكد من صحة البيانات قبل الحفظ.

## الترخيص

© 2024 مع الأنوار. جميع الحقوق محفوظة.
