# 🛒 Smart Shopper: The Ultimate Shopping Assistant

**Smart Shopper** goes beyond a simple checklist. It is a powerful, intelligent, and fully customizable shopping companion built with **Flutter** and **SQLite**. Whether you are budgeting, rushing through the market, or planning your weekly meals, Smart Shopper adapts to your needs with advanced notifications, price predictions, and smart organization.

---

## ✨ Features Breakdown

### 🧠 Intelligent & Predictive
* **🔮 Auto-Price Guesser:** The app learns! It remembers the last price you paid for an item and automatically fills it in the next time you add it.
* **🔔 Market Mode:** Never leave the store with a forgotten item. Turn this mode on when you enter the market, and the app will send you continuous notifications about your remaining items at an interval you set (e.g., every 5 minutes).

### 💸 Finance & Budgeting
* **📊 Expense Analytics:** Visual charts to track your spending habits over time.
* **💰 Expense & Tax Setter:** Set a shopping budget and configure a tax rate to calculate your true final total automatically.
* **💱 Global Currency:** Full support for changing currencies to match your country.

### 📂 Advanced Organization
* **🏪 Aisle Mode:** Automatically sorts your list by Category (e.g., Dairy, Produce, Hygiene) so you can shop efficiently aisle-by-aisle without zigzagging.
* **📌 Pin Items:** Keep urgent or high-priority items stuck to the top of your list.
* **🗓️ Move to Tomorrow:** Didn't buy it today? Swipe to instantly move items to tomorrow's plan.
* **🔃 Sorting Options:** Sort your list by Name, Price, Date, or Priority.

### 🎨 Personalization
* **🌗 Dark & Light Mode:** Seamlessly switch between modes to save battery or suit your lighting.
* **🎨 Theme Changer:** Customize the app's look with various color themes.
* **🌐 Multi-Language Support:** Change the app language to your preference.

### 🧹 List Management
* **❌ Clear Purchased:** Instantly remove all checked-off items to clean up your view.
* **🔄 Reset List:** clear the entire board to start fresh for a new trip.
* **📦 Database Backup:** All data is safely stored locally using SQLite.

---

## 📖 User Guide & Button Legend

Since Smart Shopper is packed with features, here is a guide to what the icons and buttons do:

### 🏠 Home Screen Navigation
| Icon / Button | Name | Function |
| :--- | :--- | :--- |
| ➕ (FAB) | **Add Item** | Opens the form to add a new item to your list. |
| 🔔 | **Market Mode** | Toggles the continuous notification reminder. **Long press** to set the time interval. |
| 🏪 | **Aisle Mode** | Switches the view from a standard list to a Category-based view (Dairy, Produce, etc.). |
| 📉 | **Chart/Stats** | Opens the Expense Chart to view your spending history. |
| 🧹 | **Clear Done** | Removes all items currently marked as "Purchased". |

### ⚙️ Settings & Customization
| Icon / Button | Name | Function |
| :--- | :--- | :--- |
| 🌙 / ☀️ | **Theme Mode** | Toggles between Dark Mode (night) and Light Mode (day). |
| 🎨 | **Theme Color** | Opens the color picker to change the app's primary accent color. |
| 🌍 | **Language** | Opens the menu to switch the application language. |
| 💲 | **Currency** | Change the currency symbol (e.g., $, ₹, €, £) used for prices. |
| 🔢 | **Tax/Limit** | Set your default Tax Rate (%) and Spending Limit for alerts. |

### 📝 Item Actions
| Action | Description |
| :--- | :--- |
| **Tap Item** | Mark as Purchased (Check/Uncheck). |
| **Long Press** | Edit the item details or Pin the item. |
| **Swipe Right** | **Move to Tomorrow** (Reschedule). |
| **Swipe Left** | **Delete** the item permanently. |

---

## 🚀 Getting Started

Follow these steps to install the app on your local machine for development.

### Prerequisites
* [Flutter SDK](https://flutter.dev/docs/get-started/install)
* Visual Studio Code or Android Studio
* An Android Emulator or Physical Device

### Installation

1.  **Clone the Repository**
    ```bash
    git clone [https://github.com/shrawanprajapati/shopping_list_app_flutter.git](https://github.com/shrawanprajapati/shopping_list_app_flutter.git)
    ```

2.  **Navigate to the project folder**
    ```bash
    cd shopping_list_app_flutter
    ```

3.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

4.  **Run the App**
    ```bash
    flutter run
    ```

---

## 🛠️ Technology Stack

* **Framework:** Flutter (Dart)
* **Database:** SQFlite (Local Storage)
* **State Management:** Provider
* **Notifications:** Flutter Local Notifications (For Market Mode)
* **Charts:** Fl_Chart (For Expense Tracking)

---

## 🤝 Contributing

Contributions are welcome! If you have ideas for new modes or features:

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/NewMode`)
3.  Commit your Changes (`git commit -m 'Add NewMode'`)
4.  Push to the Branch (`git push origin feature/NewMode`)
5.  Open a Pull Request

---

## 📧 Contact

**Shrawan Prajapati**
* GitHub: [shrawanprajapati](https://github.com/shrawanprajapati)
* Email: [prajapatisharawan75@gmail.com]