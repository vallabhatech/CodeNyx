# Glossary

## A

### API (Application Programming Interface)
A set of rules and protocols that allows different software applications to communicate with each other. In CodeNyx, the app communicates with Supabase via REST API.

### APK (Android Package Kit)
The file format used to distribute and install application software and middleware onto Google's Android operating system.

### App Bundle
A publishing format for Android apps that includes all the compiled code and resources, deferring APK generation and signing to Google Play.

### Async/Await
Dart keywords used to handle asynchronous operations. `async` marks a function as asynchronous, and `await` pauses execution until the async operation completes.

### Auth (Authentication)
The process of verifying the identity of a user or system. CodeNyx uses Supabase Auth with Google OAuth.

## B

### Backend
The server-side of an application that handles data storage, business logic, and API endpoints. CodeNyx uses Supabase as its backend.

### Build
The process of compiling source code into an executable application. Flutter builds can be for debug or release mode.

### BuildContext
A handle to the location of a widget in the widget tree. Used for navigation, showing dialogs, and accessing theme data.

### Bundle Identifier
A unique identifier for an iOS application, typically in reverse domain name format (e.g., com.example.codenyx).

## C

### Cache
A hardware or software component that stores data so that future requests for that data can be served faster. CodeNyx uses PostState as an in-memory cache.

### Callback
A function passed as an argument to another function, to be executed later. Commonly used for user interactions.

### Class
A blueprint for creating objects in object-oriented programming. Defines properties and methods that objects of the class will have.

### Client
The front-end application that users interact with. In CodeNyx, the Flutter app is the client.

### Column
A vertical set of data values in a database table. Each column represents a specific attribute.

### Commit
A snapshot of changes in a Git repository. Each commit has a unique ID and message.

### Component
A reusable, self-contained piece of UI. In Flutter, widgets are the components.

### Constructor
A special method called when an object is created. In Dart, constructors have the same name as the class.

### ConsumerWidget
A Flutter widget from Riverpod that can read providers and rebuild when they change.

### Container
A widget that combines common painting, positioning, and sizing widgets. One of the most commonly used widgets in Flutter.

### CORS (Cross-Origin Resource Sharing)
A security feature that allows or restricts cross-origin requests. Supabase handles CORS automatically.

### CRUD (Create, Read, Update, Delete)
The four basic operations for persistent storage. CodeNyx implements CRUD for posts, comments, messages, etc.

## D

### Dart
The programming language used by Flutter. A strongly-typed, object-oriented language with C-style syntax.

### Database
An organized collection of structured information stored electronically. CodeNyx uses PostgreSQL via Supabase.

### Debug Build
A build configuration that includes debugging information and allows hot reload, but is not optimized.

### Deep Link
A URL that directs users to specific content within an app. Used for OAuth redirects.

### Dependency
A package or library that the project relies on. Listed in pubspec.yaml.

### Deployment
The process of making an application available for use. Can be to app stores or web hosting.

### Destructor
A method called when an object is destroyed. In Flutter, `dispose()` is used to clean up resources.

### Dialog
A type of window that appears on top of the main content to request user input or display information.

### Directory
A file system structure used to organize files. CodeNyx has a specific directory structure.

### Disposable
An object that needs to be cleaned up when no longer needed. Controllers and streams in Flutter are disposable.

### DPI (Dots Per Inch)
A measure of spatial printing or video dot density. Used for responsive design.

### DRY (Don't Repeat Yourself)
A principle of software development aimed at reducing repetition of software patterns.

## E

### Element
A single part of a larger whole. In HTML, an element is a tag; in Flutter, a widget.

### Emulator
A software program that simulates a mobile device. Used for testing without physical hardware.

### Environment Variable
A dynamic-named value that can affect the behavior of running processes. Used for sensitive data like API keys.

### Error Handling
The process of responding to and recovering from error conditions. CodeNyx uses try-catch blocks.

### Event
An action or occurrence recognized by software. User taps, network responses, and timer ticks are events.

### Exception
An abnormal condition that requires special handling. In Dart, exceptions are thrown when errors occur.

### Extension
A file suffix that indicates the file type. Dart files use .dart, YAML files use .yaml.

## F

### Factory Constructor
A constructor that doesn't always create a new instance. Used in Dart for creating objects from JSON.

### Feature
A distinct piece of functionality. CodeNyx has features like social feed, chat, admin panel, etc.

### Field
A variable that belongs to a class or object. Also refers to a column in a database table.

### File
A named collection of data stored on a storage device.

### Flutter
An open-source UI software development kit created by Google. Used to build CodeNyx.

### Flutter Doctor
A command-line tool that checks the Flutter development environment and reports issues.

### Foreign Key
A field in a database table that uniquely identifies a row in another table. Used for relationships.

### Form
A collection of input fields for user data entry.

### Framework
A platform for developing software applications. Flutter is a framework.

### Function
A block of code that performs a specific task. Functions can take parameters and return values.

### Future
A Dart object representing a computation that doesn't complete immediately. Used for async operations.

## G

### Git
A distributed version control system for tracking changes in source code.

### GitHub
A web-based platform for hosting and collaborating on Git repositories.

### GoRouter
A declarative routing library for Flutter. Used in CodeNyx for navigation.

### Gradle
A build automation tool for Android projects.

### Graphical User Interface (GUI)
A visual way of interacting with a computer using icons, menus, and windows.

## H

### Hot Reload
A Flutter feature that updates the running app with code changes without restarting the app.

### Hot Restart
A Flutter feature that restarts the app with code changes, losing the app state.

### HTTP (Hypertext Transfer Protocol)
The foundation of data communication on the web. CodeNyx uses HTTPS for secure communication.

### Hybrid App
An app that can run on multiple platforms from a single codebase. Flutter apps are hybrid.

## I

### IDE (Integrated Development Environment)
A software application that provides comprehensive facilities for software development. VS Code and Android Studio are IDEs.

### Index
A database structure that improves the speed of data retrieval operations on database tables.

### Inheritance
A mechanism where a new class derives properties and methods from an existing class.

### Input
Data provided to a program or function.

### Instance
A specific occurrence of a class. An object created from a class blueprint.

### Interface
A contract that defines the behavior of a class without specifying implementation.

### iOS
The operating system developed by Apple for iPhone and iPad devices.

### IPA (iPhone Application)
The file format used to distribute and install applications on iOS devices.

### Iterable
A collection of elements that can be accessed sequentially. Lists and sets are iterables.

## J

### JSON (JavaScript Object Notation)
A lightweight data interchange format. Used for API requests and responses.

### JIT (Just-In-Time) Compilation
Compilation that happens at runtime. Flutter uses JIT during development for hot reload.

## K

### Key
A value used to identify a record in a database. Primary keys uniquely identify records.

### Keystore
A file containing private keys and certificates used for signing Android apps.

## L

### Lint
A tool that analyzes source code to flag programming errors, bugs, and style issues.

### List
An ordered collection of items in Dart.

### Listener
An object that waits for events or changes. Riverpod providers notify listeners when state changes.

### Local State
State that is managed within a single widget and not shared with other widgets.

### Log
A record of events that occur during program execution. Used for debugging.

## M

### Material Design
Google's design language for Android and web. CodeNyx uses Material Design widgets.

### Method
A function that belongs to a class or object.

### Middleware
Software that provides common services and capabilities to applications outside of what's offered by the operating system.

### Model
A class that represents data structures. MessageModel, PostModel are examples.

### Module
A self-contained unit of functionality. CodeNyx is organized into feature modules.

### Mutable
Something that can be changed. Lists in Dart are mutable.

## N

### Navigation
The process of moving between different screens in an app.

### Network
A collection of computers connected together to share resources.

### Null
A value that represents the absence of a value. Dart has sound null safety.

### Null Safety
A feature in Dart that prevents null reference errors by distinguishing between nullable and non-nullable types.

## O

### Object
An instance of a class. Objects have state (properties) and behavior (methods).

### OAuth
An open standard for access delegation. CodeNyx uses Google OAuth for authentication.

### Onboarding
The process of getting new users started with an application.

### Operator
A symbol that performs an operation on one or more operands. +, -, *, / are operators.

### Optimization
The process of modifying a system to make it more efficient.

## P

### Package
A collection of Dart code that can be reused across projects. Listed in pubspec.yaml.

### Pagination
The process of dividing large datasets into smaller chunks (pages) for easier consumption.

### Parameter
A variable in a function definition. Arguments are passed to parameters.

### Platform
The operating system or environment on which an app runs. iOS, Android, and Web are platforms.

### Plugin
A package that provides platform-specific functionality. image_picker is a plugin.

### Pointer
A reference to a memory location. Dart doesn't have explicit pointers.

### Primary Key
A unique identifier for a record in a database table.

### Private
Access modifier that restricts visibility to the same library. Prefixed with underscore in Dart.

### Provider
A pattern for state management. Riverpod is a provider-based state management solution.

### ProviderScope
A widget that provides the scope for Riverpod providers in the application.

### Pub
The package manager for Dart and Flutter.

### pub.dev
The official repository for Dart and Flutter packages.

### pubspec.yaml
The configuration file for a Flutter project, listing dependencies and metadata.

### Pull Request
A mechanism to propose changes to a codebase in version control systems like GitHub.

## Q

### Query
A request for data from a database. SQL queries are used to retrieve data.

### Queue
A data structure that follows First-In-First-Out (FIFO) principle.

## R

### RLS (Row Level Security)
A database security feature that restricts which rows a user can access based on their identity.

### Real-time
Data that is delivered immediately as it's generated. Supabase Realtime provides this.

### Record
A row in a database table containing data for a single entity.

### Ref
The reference to a Riverpod provider, used to read and watch state.

### Refresh
The process of reloading data to get the latest updates.

### Release Build
A build configuration optimized for performance and size, without debugging information.

### Repository
A design pattern that mediates between the domain and data mapping layers. CodeNyx uses repositories for data access.

### Response
Data returned from a server after a request.

### Riverpod
A reactive caching framework for Dart/Flutter. Used for state management in CodeNyx.

### Route
A path that maps to a specific screen in the application.

### Router
The system that handles navigation between routes. go_router is used in CodeNyx.

### Row
A horizontal set of data in a database table.

### RPC (Remote Procedure Call)
A protocol that allows a program to execute a procedure on another computer.

### Run
The process of executing an application.

## S

### SDK (Software Development Kit)
A set of tools for creating applications. Flutter SDK includes the Dart SDK and Flutter tools.

### Screen
A full-page view in an application. A screen is typically a widget that occupies the entire viewport.

### Scroll
The action of moving content vertically or horizontally within a viewport.

### Secure Storage
Encrypted storage for sensitive data like tokens and keys.

### Serialization
The process of converting data structures into a format that can be stored or transmitted.

### Service
A reusable component that provides specific functionality. SessionService is an example.

### Session
A temporary interaction between a user and the application. Auth sessions track user login state.

### Singleton
A design pattern that restricts a class to a single instance.

### Snapshot
A captured state of data at a specific point in time.

### SQL (Structured Query Language)
A language for managing relational databases.

### State
The data that a widget needs to render. State can change over time.

### StatefulWidget
A Flutter widget that has mutable state.

### StatelessWidget
A Flutter widget that doesn't have mutable state.

### Stream
A sequence of asynchronous events. Used for real-time data in CodeNyx.

### StreamProvider
A Riverpod provider that exposes a stream and rebuilds when new data arrives.

### String
A sequence of characters. Used for text data.

### Style
The visual appearance of UI elements. CodeNyx uses AppTheme for styling.

### Supabase
An open-source Firebase alternative. Used as the backend for CodeNyx.

### Supabase Auth
The authentication service provided by Supabase.

### Supabase Storage
The file storage service provided by Supabase.

### Sync
The process of making data consistent across different sources.

## T

### Table
A collection of related data in a database, organized in rows and columns.

### Test
Code written to verify that other code works correctly.

### Theme
A collection of visual styles for an application. CodeNyx has a dark theme.

### Token
A piece of data that represents a user's session or permission.

### Transaction
A sequence of database operations treated as a single unit.

### Tree
A hierarchical data structure. Flutter's widget tree is an example.

### Try-Catch
A pattern for handling exceptions. Code in the try block is executed; exceptions are caught in the catch block.

### Tuple
An ordered list of elements. Dart doesn't have built-in tuples but uses records.

### Type
A classification of data that determines the operations that can be performed on it.

## U

### UI (User Interface)
The visual part of a computer system that users interact with.

### URL (Uniform Resource Locator)
An address that identifies a resource on the internet.

### UUID (Universally Unique Identifier)
A 128-bit number used to identify information in computer systems.

### Unit Test
A test that verifies a small piece of code in isolation.

### User
A person who uses the application.

### User Experience (UX)
The overall experience of a person using a product or system.

## V

### Validation
The process of checking that data meets certain requirements.

### Variable
A named storage location for data.

### Version
A specific iteration of software. CodeNyx uses semantic versioning.

### View
The visual representation of data. In Flutter, widgets are views.

### ViewModel
A component that prepares data for the view. Not explicitly used in CodeNyx.

### VS Code
Visual Studio Code, a popular code editor for Flutter development.

## W

### Widget
The basic building block of Flutter UI. Everything in Flutter is a widget.

### Widget Tree
The hierarchy of widgets in a Flutter application.

### Web
A platform for running applications in web browsers.

### WebSocket
A communication protocol that provides full-duplex communication channels. Used by Supabase Realtime.

### While Loop
A control flow statement that repeats code while a condition is true.

### Wi-Fi
A wireless networking technology.

## X

### Xcode
Apple's integrated development environment for macOS, used for iOS development.

### XML (eXtensible Markup Language)
A markup language that defines rules for encoding documents. Used in AndroidManifest.xml.

## Y

### YAML (YAML Ain't Markup Language)
A human-readable data serialization language. Used for pubspec.yaml and configuration files.

## Z

### Zone
An execution context in Dart that can be used for error handling and testing.
