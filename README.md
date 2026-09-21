#  4S Essentials App

**4S Essentials** is a feature-rich, full-stack E-Commerce mobile application built using **Flutter** and **Firebase**. It provides a sleek, modern shopping experience for customers alongside a powerful admin dashboard for inventory management, sales reporting, and analytics.

---

##  Key Features

###  Customer App Experience
- **Onboarding & Splash Screen:** Engaging visual intro screens with animated transitions (`animate_do`).
- **User Authentication:** Secure signup, login, and session persistence via **Firebase Auth**.
-  **Home & Category Showcase:** Dynamic product catalog with category filtering and search functionality.
-  **Wishlist:** Quick product bookmarking for future purchases.
-  **Shopping Cart & Checkout:** Real-time cart calculations and order processing.
-  **Order History & Tracking:** Detailed view of current and completed orders.
-  **User Profile:** Manage personal details and delivery addresses.

###  Admin Management Panel
-  **Business Analytics:** Interactive charts powered by `fl_chart` for revenue and sales metrics.
-  **Product & Inventory Management:** Add, update, or remove products and upload product images to **Firebase Storage**.
-  **PDF Invoice & Sales Reports:** Generate and print PDF invoices or share reports using `pdf`, `printing`, and `share_plus`.
-  **Order Fulfillment:** Real-time view of customer orders and status updates using **Cloud Firestore**.

---

##  Tech Stack & Dependencies

- **Framework:** [Flutter](https://flutter.dev) (Dart SDK `^3.10.1`)
- **Backend Services:** 
  - `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
- **UI & Animations:** 
  - `flutter_screenutil` (Responsive Layouts)
  - `google_fonts` (Custom Typography)
  - `animate_do` (Smooth UI Animations)
  - `cupertino_icons`
- **Analytics & Reporting:** 
  - `fl_chart` (Data Visualization)
  - `pdf` & `printing` (PDF Document Generation & Printing)
  - `share_plus` & `path_provider` (Document Sharing & File Access)
  - `image_picker` (Product Image Selection)
