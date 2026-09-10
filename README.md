# معهد الأنوار - Al-Anwar Institute

تطبيق إدارة معهد تعليمي بالكامل مبني بـ Flutter + Firebase.

## الميزات
- لوحة تحكم المدير مع إحصائيات حية
- إدارة الطلاب (إضافة/تعديل/حذف/تفعيل/تعطيل)
- إدارة المدرسين (إضافة/تعديل/حذف/تفعيل/تعطيل)
- إدارة الشعب والمواد والجدول
- ربط الشعبة بالمادة والمدرس والقاعة
- نظام أقساط كامل (الكلي/المدفوع/المتبقي/الحالة)
- تسجيل الحضور والغياب
- الإعلانات والواجبات
- تقارير الأقساط
- لوحة تحكم الطالب
- لوحة تحكم المدرس
- رسائل تحذيرية لكل إجراء خطير

##How to Setup

### 1. تثبيت Flutter
```bash
# Windows
# حمّل Flutter SDK من: https://docs.flutter.dev/get-started/install/windows

# تحقق من التثبيت
flutter doctor
```

### 2. إعداد Firebase
```bash
# تثبيت Firebase CLI
npm install -g firebase-tools

# تسجيل الدخول
firebase login

# تثبيت flutterfire CLI
dart pub global activate flutterfire_cli

# إعداد Firebase للمشروع
flutterfire configure
```

### 3. إنشاء حساب المدير
1. افتح Firebase Console: https://console.firebase.google.com
2. اختر مشروع **al-anwar-institute**
3. **Authentication** ← **Users** ← **Add user**
4. أضف مستخدم:
   - Email: `admin@alanwar.edu`
   - Password: `Admin@123456`
5. اذهب إلى **Firestore Database** ← **Start collection**
6. أنشئ مجموعة `users` مع document جديد:
   - Document ID: (same as Firebase Auth UID)
   - Fields:
     - `uid`: (same as Firebase Auth UID)
     - `displayName`: `مدير المعهد`
     - `email`: `admin@alanwar.edu`
     - `username`: `admin`
     - `role`: `admin`
     - `isActive`: `true`
     - `createdAt`: (current timestamp)

### 4. تشغيل التطبيق
```bash
flutter pub get
flutter run
```

### 5. بناء APK
```bash
flutter build apk --release
```

### 6. بناء Web
```bash
flutter build web --release --base-href="/"
```

## Firebase Collections

| Collection | الوصف |
|---|---|
| `users` | حسابات المستخدمين (مدير/مدرس/طالب) |
| `students` | بيانات الطلاب |
| `teachers` | بيانات المدرسين |
| `classes` | الشعب (مرتبطة بالصف والفرع) |
| `subjects` | المواد (مرتبطة بالمدرس والفصول) |
| `schedules` | الجدول (مرتبط بالشعبة والمدرس والقاعة) |
| `attendance` | سجل الحضور والغياب |
| `payments` | الأقساط والمدفوعات |
| `assignments` | الواجبات |
| `announcements` | الإعلانات |
| `counters` | عداد لتوليد الأرقام التسلسلية |

## هيكل الأرقام التسلسلية
- الطلاب: `STU-1001`, `STU-1002`, ...
- المدرسين: `TCH-1001`, `TCH-1002`, ...

## بيانات الدخول الافتراضية
| الحقل | القيمة |
|---|---|
| اسم المستخدم | `admin` |
| البريد الإلكتروني | `admin@alanwar.edu` |
| كلمة المرور | `Admin@123456` |
