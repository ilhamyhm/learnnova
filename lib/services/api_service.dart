import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/checkpoint_model.dart';
import '../models/material_model.dart';
import '../models/quiz_model.dart';

/// Central API service for LearnNova.
/// Fetches learning materials (16 per topic), checkpoint questions (4 per topic),
/// and final quizzes (20 questions per topic) from a REST API.
/// Falls back to rich built-in mock data when the backend is unreachable.
class ApiService {
  static const String _baseUrl = 'https://learnnova-api.example.com';

  // ─── SharedPreferences Keys (legacy — kept for backward compat) ──────────
  static const String _keyViewedSlides = 'viewed_slides_';
  static const String _keyQuizScore   = 'quiz_score_';
  static const String _keyQuizPassed  = 'quiz_passed_';
  static const String _keyMatProgress = 'mat_progress_';

  // ─── Materials ───────────────────────────────────────────────────────────

  Future<ModuleMaterialsResponse> fetchMaterials(String subModuleKey) async {
    try {
      final uri = Uri.parse('$_baseUrl/materials/$subModuleKey');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        return ModuleMaterialsResponse.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      }
    } catch (_) {}
    return _mockMaterials(subModuleKey);
  }

  // ─── Quizzes ─────────────────────────────────────────────────────────────

  Future<ModuleQuizResponse> fetchQuiz(String subModuleKey) async {
    try {
      final uri = Uri.parse('$_baseUrl/quizzes/$subModuleKey');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        return ModuleQuizResponse.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      }
    } catch (_) {}
    return _mockQuiz(subModuleKey);
  }

  // ─── Checkpoint Questions ─────────────────────────────────────────────────

  /// Returns the checkpoint question shown after [afterSlideIndex] (1-based: 4, 8, 12, 16).
  CheckpointQuestion? fetchCheckpoint(String subModuleKey, int afterSlideIndex) {
    final key = '${subModuleKey}_cp${afterSlideIndex}';
    return _allCheckpoints[key] ?? _generateCheckpoint(subModuleKey, afterSlideIndex);
  }

  // ─── Progress Persistence (legacy — use UserProgressService instead) ──────

  Future<Set<int>> getViewedSlides(String subModuleKey) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('$_keyViewedSlides$subModuleKey') ?? [];
    return stored.map(int.parse).toSet();
  }

  Future<void> markSlideViewed(String subModuleKey, int slideId) async {
    final prefs = await SharedPreferences.getInstance();
    final viewed = await getViewedSlides(subModuleKey);
    viewed.add(slideId);
    await prefs.setStringList(
      '$_keyViewedSlides$subModuleKey',
      viewed.map((e) => e.toString()).toList(),
    );
  }

  Future<double> getMaterialProgress(String subModuleKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('$_keyMatProgress$subModuleKey') ?? 0.0;
  }

  Future<void> updateMaterialProgress(
    String subModuleKey,
    int viewedCount,
    int totalSlides,
  ) async {
    if (totalSlides == 0) return;
    final prefs = await SharedPreferences.getInstance();
    final progress = (viewedCount / totalSlides).clamp(0.0, 1.0);
    await prefs.setDouble('$_keyMatProgress$subModuleKey', progress);
  }

  Future<double?> getQuizScore(String subModuleKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('$_keyQuizScore$subModuleKey')
        ? prefs.getDouble('$_keyQuizScore$subModuleKey')
        : null;
  }

  Future<bool> isQuizPassed(String subModuleKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_keyQuizPassed$subModuleKey') ?? false;
  }

  Future<void> saveQuizResult(
    String subModuleKey,
    double scorePercent,
    bool passed,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('$_keyQuizScore$subModuleKey', scorePercent);
    await prefs.setBool('$_keyQuizPassed$subModuleKey', passed);
  }

  // ─── Mock Data Builders ───────────────────────────────────────────────────

  ModuleMaterialsResponse _mockMaterials(String key) {
    var data = _allMockMaterials[key];
    if (data == null) {
      return _generateMaterials(key);
    }
    // Enforce exactly 16 materials
    final rawList = data['materials'] as List;
    final list = rawList.length >= 16
        ? rawList.take(16).toList()
        : _padMaterials(rawList, key, 16);
    final result = Map<String, dynamic>.from(data);
    result['materials'] = list;
    result['total_slide'] = 16;
    return ModuleMaterialsResponse.fromJson(result);
  }

  List<dynamic> _padMaterials(List<dynamic> existing, String key, int target) {
    final padded = List<dynamic>.from(existing);
    for (var i = padded.length + 1; i <= target; i++) {
      padded.add({
        'material_id': i,
        'title': 'Advanced Concept $i',
        'content':
            'This lesson covers an advanced aspect of ${key.replaceAll('_', ' ')}. '
            'Building on what you have learned in the previous slides, you will deepen your understanding '
            'and explore real-world applications of this topic.',
        'example': null,
      });
    }
    return padded;
  }

  ModuleMaterialsResponse _generateMaterials(String key) {
    final title = key.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
    return ModuleMaterialsResponse.fromJson({
      'module_id': 0,
      'title': title,
      'level': 'Beginner',
      'tujuan_pembelajaran': 'Master the core concepts of $title.',
      'total_slide': 16,
      'materials': List.generate(16, (i) => {
        'material_id': i + 1,
        'title': _lessonTitles[i % _lessonTitles.length].replaceAll('{topic}', title),
        'content':
            'Lesson ${i + 1}: ${_lessonContents[i % _lessonContents.length].replaceAll('{topic}', title)}',
        'example': i % 3 == 0 ? '// Example for $title lesson ${i + 1}\n// Practice this concept in your project' : null,
      }),
    });
  }

  static const List<String> _lessonTitles = [
    'Introduction to {topic}',
    'Core Concepts of {topic}',
    'Fundamentals: Key Terminology',
    'Building Blocks',
    'Practical Techniques',
    'Advanced Methods',
    'Real-World Applications',
    'Common Patterns',
    'Best Practices',
    'Debugging & Problem Solving',
    'Performance Optimization',
    'Integration Strategies',
    'Case Studies',
    'Project Walkthrough',
    'Review & Consolidation',
    'Next Steps & Resources',
  ];

  static const List<String> _lessonContents = [
    '{topic} is a fundamental skill that opens doors to countless opportunities. In this lesson, we explore what {topic} is, why it matters, and how you can get started on your learning journey.',
    'Every discipline has core concepts that form the foundation. For {topic}, these include the key principles, terminology, and mental models that experts use every day.',
    'Understanding the terminology of {topic} is essential. We will cover the most important terms and definitions you need to communicate effectively and understand advanced resources.',
    'Just as a building needs a solid foundation, mastery of {topic} starts with understanding its building blocks. We will break these down into digestible components.',
    'Theory is valuable, but practice is where learning becomes permanent. In this lesson, we apply the concepts you have learned to practical exercises and scenarios.',
    'Advanced practitioners of {topic} use specialized methods that go beyond the basics. We will introduce these techniques and show you when and how to apply them.',
    '{topic} is used across many industries and domains. We will explore real-world examples and case studies that demonstrate the power and versatility of these skills.',
    'Experienced practitioners recognize recurring patterns in {topic}. Learning these patterns helps you solve new problems faster by applying proven solutions.',
    'Following best practices in {topic} ensures your work is maintainable, efficient, and professional. We cover industry standards and recommended approaches.',
    'Even experts encounter problems. This lesson teaches you systematic debugging strategies and problem-solving frameworks specific to {topic}.',
    'As you advance in {topic}, performance becomes important. We explore techniques to make your work faster, leaner, and more effective.',
    'Rarely does {topic} exist in isolation. Learn how to integrate it with other tools, systems, and workflows to create powerful, complete solutions.',
    'Real-world success stories provide powerful lessons. We analyze cases where {topic} made a significant difference and extract the key takeaways.',
    'Walk through a complete project using {topic} from start to finish. This guided example consolidates everything you have learned into a cohesive whole.',
    'In this lesson, we review all the key concepts from this module, reinforce the most important ideas, and fill in any gaps in your understanding.',
    'Your learning journey does not end here. We provide a roadmap for continued growth, resources for further study, and guidance on how to apply your new skills.',
  ];

  ModuleQuizResponse _mockQuiz(String subModuleKey) {
    final data = _allMockQuizzes[subModuleKey];
    if (data != null) {
      final rawQ = data['questions'] as List;
      final questions = rawQ.length >= 20
          ? rawQ.take(20).toList()
          : _padQuestions(rawQ, subModuleKey, 20);
      final result = Map<String, dynamic>.from(data);
      result['questions'] = questions;
      return ModuleQuizResponse.fromJson(result);
    }
    return _generateQuiz(subModuleKey);
  }

  List<dynamic> _padQuestions(List<dynamic> existing, String key, int target) {
    final padded = List<dynamic>.from(existing);
    final title = key.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
    for (var i = padded.length + 1; i <= target; i++) {
      padded.add({
        'question_id': i,
        'question': 'Which of the following best describes a key concept in $title (Q$i)?',
        'options': ['Systematic approach', 'Random selection', 'Avoiding the topic', 'Ignoring best practices'],
        'correct_answer': 'Systematic approach',
      });
    }
    return padded;
  }

  ModuleQuizResponse _generateQuiz(String subModuleKey) {
    final title = subModuleKey.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
    return ModuleQuizResponse.fromJson({
      'module_id': 0,
      'quiz_title': '$title — Final Quiz',
      'questions': List.generate(20, (i) => {
        'question_id': i + 1,
        'question': _quizTemplates[i % _quizTemplates.length].replaceAll('{topic}', title).replaceAll('{n}', '${i + 1}'),
        'options': ['Systematic approach', 'Random selection', 'Avoiding best practices', 'Ignoring the fundamentals'],
        'correct_answer': 'Systematic approach',
      }),
    });
  }

  CheckpointQuestion _generateCheckpoint(String subModuleKey, int afterSlideIndex) {
    final title = subModuleKey.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
    return CheckpointQuestion(
      question: 'After studying slides 1–$afterSlideIndex of $title, which approach is most effective for learning?',
      options: ['Active practice with real examples', 'Passive reading only', 'Skipping difficult sections', 'Memorizing without understanding'],
      correctAnswer: 'Active practice with real examples',
      explanation: 'Active practice with real examples helps reinforce concepts through hands-on experience, leading to deeper understanding and better retention.',
    );
  }

  static const List<String> _quizTemplates = [
    'What is the primary purpose of {topic}?',
    'Which of the following is a fundamental concept in {topic}?',
    'What is the best practice when working with {topic}?',
    'How does {topic} benefit real-world applications?',
    'Which approach is most effective when learning {topic}?',
    'What is a common challenge when applying {topic}?',
    'Which tool or technique is most associated with {topic}?',
    'What principle underlies the core of {topic}?',
    'When should you apply advanced techniques in {topic}?',
    'What does proper {topic} implementation improve?',
    'Which step comes first when starting a {topic} project?',
    'What is an example of best practices in {topic}?',
    'How do professionals typically debug issues in {topic}?',
    'What is the long-term benefit of mastering {topic}?',
    'Which skill is most critical for success in {topic}?',
    'How does {topic} integrate with other disciplines?',
    'What should you do when facing a complex {topic} problem?',
    'What metric indicates success in a {topic} project?',
    'How do you stay current with developments in {topic}?',
    'What is the most important takeaway from studying {topic} question {n}?',
  ];

  // ─── Mock Checkpoint Data ────────────────────────────────────────────────

  static final Map<String, CheckpointQuestion> _allCheckpoints = {
    // HTML checkpoints
    'codelab_html_cp4': CheckpointQuestion(
      question: 'Which HTML tag is used to define the largest heading?',
      options: ['<h6>', '<h1>', '<head>', '<title>'],
      correctAnswer: '<h1>',
      explanation: '<h1> defines the most important heading. HTML has six levels, from <h1> (largest) to <h6> (smallest). Using proper heading hierarchy is important for SEO and accessibility.',
    ),
    'codelab_html_cp8': CheckpointQuestion(
      question: 'What attribute is required in an <img> tag for accessibility?',
      options: ['src', 'href', 'alt', 'class'],
      correctAnswer: 'alt',
      explanation: 'The "alt" attribute provides alternative text for images. Screen readers use it for visually impaired users, and it appears when the image fails to load. It is essential for web accessibility.',
    ),
    'codelab_html_cp12': CheckpointQuestion(
      question: 'Which HTML element creates an unordered list?',
      options: ['<ol>', '<li>', '<ul>', '<list>'],
      correctAnswer: '<ul>',
      explanation: '<ul> creates an unordered (bulleted) list. <ol> creates an ordered (numbered) list. Both use <li> elements for individual list items.',
    ),
    'codelab_html_cp16': CheckpointQuestion(
      question: 'What does the "action" attribute in a <form> tag specify?',
      options: ['The form style', 'Where form data is sent', 'The input type', 'The button label'],
      correctAnswer: 'Where form data is sent',
      explanation: 'The "action" attribute defines the URL where form data is submitted when the user clicks the submit button. Without it, the form submits to the current page.',
    ),

    // CSS checkpoints
    'codelab_css_cp4': CheckpointQuestion(
      question: 'Which CSS property changes the text color?',
      options: ['font-color', 'text-color', 'color', 'background-color'],
      correctAnswer: 'color',
      explanation: 'The "color" property sets the foreground color of text in CSS. "background-color" sets the background, while "font-color" and "text-color" are not valid CSS properties.',
    ),
    'codelab_css_cp8': CheckpointQuestion(
      question: 'In the CSS Box Model, which layer is outermost?',
      options: ['Content', 'Padding', 'Border', 'Margin'],
      correctAnswer: 'Margin',
      explanation: 'The CSS Box Model has four layers from inside out: Content → Padding → Border → Margin. Margin is the outermost, creating space between elements.',
    ),
    'codelab_css_cp12': CheckpointQuestion(
      question: 'Which CSS value makes a container use Flexbox layout?',
      options: ['display: block', 'display: flex', 'display: grid', 'display: inline'],
      correctAnswer: 'display: flex',
      explanation: '"display: flex" activates Flexbox on a container, enabling powerful alignment and distribution of child elements along one axis.',
    ),
    'codelab_css_cp16': CheckpointQuestion(
      question: 'What CSS rule is used to apply styles at specific screen sizes?',
      options: ['@keyframes', '@font-face', '@media', '@import'],
      correctAnswer: '@media',
      explanation: '@media queries apply CSS styles conditionally based on viewport size, enabling responsive design. For example: @media (max-width: 768px) applies styles only on small screens.',
    ),

    // Python checkpoints
    'codelab_python_cp4': CheckpointQuestion(
      question: 'How do you print "Hello, World!" in Python?',
      options: ['echo("Hello, World!")', 'print("Hello, World!")', 'console.log("Hello, World!")', 'System.out.println("Hello, World!")'],
      correctAnswer: 'print("Hello, World!")',
      explanation: 'Python uses the print() function to output text. Unlike other languages, Python does not require semicolons at the end of statements.',
    ),
    'codelab_python_cp8': CheckpointQuestion(
      question: 'What data type stores key-value pairs in Python?',
      options: ['List', 'Tuple', 'Set', 'Dictionary'],
      correctAnswer: 'Dictionary',
      explanation: 'A Python dictionary (dict) stores data as key-value pairs: {"name": "Ali", "age": 25}. They are mutable, unordered (in older Python), and allow fast lookups by key.',
    ),
    'codelab_python_cp12': CheckpointQuestion(
      question: 'Which keyword defines a function in Python?',
      options: ['func', 'function', 'def', 'define'],
      correctAnswer: 'def',
      explanation: 'Python uses the "def" keyword to define functions: def my_function(): ... Functions encapsulate reusable blocks of code.',
    ),
    'codelab_python_cp16': CheckpointQuestion(
      question: 'What does the range() function return in Python?',
      options: ['A list of numbers', 'A range object', 'A tuple', 'A string'],
      correctAnswer: 'A range object',
      explanation: 'range() returns a range object (not a list) that generates numbers on demand. Use list(range(5)) to get [0, 1, 2, 3, 4]. It is commonly used in for loops.',
    ),
  };

  // ─── Mock Material Data ──────────────────────────────────────────────────

  static final Map<String, Map<String, dynamic>> _allMockMaterials = {
    'codelab_html': {
      'module_id': 1,
      'title': 'HTML Fundamentals',
      'level': 'Beginner',
      'tujuan_pembelajaran': 'Master HTML structure, elements, forms, and accessibility to build complete web pages.',
      'total_slide': 16,
      'materials': [
        {'material_id': 1, 'title': 'What is HTML?', 'content': 'HTML (HyperText Markup Language) is the standard language for creating web pages. It describes the structure of web content using a series of elements that tell the browser how to display content. HTML is not a programming language — it is a markup language that uses tags to annotate text, images, and other content for display.', 'example': '<!DOCTYPE html>\n<html>\n  <head><title>My First Page</title></head>\n  <body><h1>Hello World!</h1></body>\n</html>'},
        {'material_id': 2, 'title': 'HTML Elements & Tags', 'content': 'HTML elements are represented by tags enclosed in angle brackets. Most elements have an opening tag and a closing tag. The content sits between them. Some elements are self-closing (void elements) and do not need a closing tag. Tags can be nested to build complex structures.', 'example': '<h1>Heading</h1>\n<p>Paragraph text here.</p>\n<br> <!-- self-closing -->\n<img src="photo.jpg" alt="A photo">'},
        {'material_id': 3, 'title': 'Headings & Paragraphs', 'content': 'HTML provides six levels of headings from <h1> (most important) to <h6> (least important). Headings define the hierarchical structure of your content. Paragraphs use the <p> tag. Browsers add default spacing around block elements like headings and paragraphs.', 'example': '<h1>Main Title</h1>\n<h2>Section Heading</h2>\n<h3>Sub-section</h3>\n<p>This is a regular paragraph with some text content.</p>'},
        {'material_id': 4, 'title': 'Links & Anchor Tags', 'content': 'Hyperlinks are created with the <a> (anchor) tag. The href attribute specifies the URL destination. Links can be absolute (full URL) or relative (path on the same site). The target="_blank" attribute opens the link in a new tab. The title attribute provides tooltip text on hover.', 'example': '<a href="https://flutter.dev">Visit Flutter</a>\n<a href="/about" title="About us">About</a>\n<a href="mailto:hello@example.com">Email us</a>\n<a href="tel:+123456789">Call us</a>'},
        {'material_id': 5, 'title': 'Images in HTML', 'content': 'Images are inserted with the <img> tag, which is a void element (self-closing). The src attribute specifies the image source (URL or file path). The alt attribute provides alternative text for accessibility and when the image fails to load. Width and height attributes control display dimensions.', 'example': '<img src="logo.png" alt="LearnNova Logo" width="200">\n<img src="https://example.com/photo.jpg" alt="Remote image" style="border-radius: 8px;">'},
        {'material_id': 6, 'title': 'Lists — Ordered & Unordered', 'content': 'HTML supports ordered lists (numbered with <ol>), unordered lists (bulleted with <ul>), and description lists (<dl>). Each item in a list uses the <li> tag. Lists can be nested inside other lists to create hierarchical structures like navigation menus.', 'example': '<ul>\n  <li>HTML</li>\n  <li>CSS</li>\n  <li>JavaScript</li>\n</ul>\n\n<ol>\n  <li>Plan your project</li>\n  <li>Write the HTML</li>\n  <li>Add CSS styling</li>\n</ol>'},
        {'material_id': 7, 'title': 'HTML Tables', 'content': 'Tables organise data into rows and columns. The <table> element wraps the whole table. <thead> contains header rows, <tbody> contains data rows. Each row uses <tr>. Header cells use <th>, data cells use <td>. The colspan and rowspan attributes allow cells to span multiple columns or rows.', 'example': '<table border="1">\n  <thead>\n    <tr><th>Name</th><th>Score</th></tr>\n  </thead>\n  <tbody>\n    <tr><td>Ali</td><td>95</td></tr>\n    <tr><td>Budi</td><td>88</td></tr>\n  </tbody>\n</table>'},
        {'material_id': 8, 'title': 'HTML Forms Basics', 'content': 'Forms collect user input and submit it to a server. The <form> element wraps all form controls. The action attribute specifies where data is sent. The method attribute specifies HTTP method (GET or POST). Common input types include text, email, password, and checkbox.', 'example': '<form action="/submit" method="post">\n  <label for="name">Name:</label>\n  <input type="text" id="name" name="name" required>\n\n  <label for="email">Email:</label>\n  <input type="email" id="email" name="email">\n\n  <input type="submit" value="Submit">\n</form>'},
        {'material_id': 9, 'title': 'Input Types', 'content': 'The <input> element supports many types that provide appropriate UI controls and validation. Common types include: text, email, password, number, date, checkbox, radio, file, and range. HTML5 introduced many new input types that improve mobile usability and built-in validation.', 'example': '<input type="text" placeholder="Your name">\n<input type="email" placeholder="email@example.com">\n<input type="number" min="1" max="100">\n<input type="date">\n<input type="checkbox" id="agree"> <label for="agree">I agree</label>\n<input type="range" min="0" max="100" value="50">'},
        {'material_id': 10, 'title': 'Semantic HTML5 Elements', 'content': 'HTML5 introduced semantic elements that describe their meaning to both the browser and developer. These improve accessibility and SEO. Key semantic elements include <header>, <nav>, <main>, <article>, <section>, <aside>, and <footer>. Using them makes your code more meaningful and easier to maintain.', 'example': '<header>\n  <nav>...</nav>\n</header>\n<main>\n  <article>\n    <h1>Article Title</h1>\n    <p>Content...</p>\n  </article>\n  <aside>Related links</aside>\n</main>\n<footer>Copyright 2025</footer>'},
        {'material_id': 11, 'title': 'HTML Attributes', 'content': 'Attributes provide additional information about HTML elements. They are placed in the opening tag as name="value" pairs. Common attributes include id (unique identifier), class (for CSS styling), style (inline styles), title (tooltip), data-* (custom data), and ARIA attributes for accessibility.', 'example': '<div id="hero" class="container featured" data-theme="dark">\n  <button class="btn primary" aria-label="Get started">\n    Get Started\n  </button>\n</div>'},
        {'material_id': 12, 'title': 'HTML Media Elements', 'content': 'HTML5 provides native support for audio and video without plugins. The <video> element embeds video with controls, autoplay, and loop attributes. The <audio> element embeds audio players. The <source> element inside them specifies multiple formats for browser compatibility.', 'example': '<video width="640" controls poster="thumbnail.jpg">\n  <source src="video.mp4" type="video/mp4">\n  <source src="video.webm" type="video/webm">\n  Your browser does not support video.\n</video>\n\n<audio controls>\n  <source src="audio.mp3" type="audio/mpeg">\n</audio>'},
        {'material_id': 13, 'title': 'HTML Meta Tags & SEO', 'content': 'Meta tags in the <head> section provide metadata about the page. They are invisible to users but crucial for browsers, search engines, and social media platforms. Important meta tags include charset, viewport (for responsive design), description (for SEO snippets), and Open Graph tags (for social sharing).', 'example': '<head>\n  <meta charset="UTF-8">\n  <meta name="viewport" content="width=device-width, initial-scale=1.0">\n  <meta name="description" content="Learn HTML with LearnNova">\n  <meta property="og:title" content="LearnNova HTML Course">\n  <title>HTML Course | LearnNova</title>\n</head>'},
        {'material_id': 14, 'title': 'HTML Accessibility', 'content': 'Web accessibility ensures your content is usable by everyone, including people with disabilities. Key practices include: using semantic elements, providing alt text for images, labelling form inputs, ensuring sufficient colour contrast, using ARIA roles and attributes, and structuring content with proper heading hierarchy.', 'example': '<button aria-label="Close dialog" onclick="closeModal()">\n  <span aria-hidden="true">✕</span>\n</button>\n\n<input type="search" \n       aria-label="Search courses"\n       role="searchbox"\n       placeholder="Search...">'},
        {'material_id': 15, 'title': 'HTML Best Practices', 'content': 'Following best practices ensures your HTML is maintainable, accessible, and performant. Always declare the DOCTYPE, use lowercase tags and attributes, quote all attribute values, close all non-void elements, validate your HTML, use external CSS and JS files instead of inline styles, and organise your document structure logically.', 'example': '<!-- Good practice -->\n<!DOCTYPE html>\n<html lang="en">\n<head>\n  <meta charset="UTF-8">\n  <link rel="stylesheet" href="styles.css">\n</head>\n<body>\n  <h1>Clean HTML</h1>\n  <script src="app.js" defer></script>\n</body>\n</html>'},
        {'material_id': 16, 'title': 'Building Your First Complete Webpage', 'content': 'Now you have the knowledge to build a complete webpage! A professional webpage combines all the elements you have learned: a semantic document structure, accessible markup, meaningful headings, images with alt text, navigation links, a contact form, and properly structured content. Let us put it all together.', 'example': '<!DOCTYPE html>\n<html lang="en">\n<head>\n  <meta charset="UTF-8">\n  <meta name="viewport" content="width=device-width, initial-scale=1.0">\n  <title>My Portfolio</title>\n</head>\n<body>\n  <header><h1>My Name</h1><nav>...</nav></header>\n  <main>\n    <section id="about"><h2>About Me</h2><p>...</p></section>\n    <section id="contact"><h2>Contact</h2><form>...</form></section>\n  </main>\n  <footer><p>&copy; 2025</p></footer>\n</body>\n</html>'},
      ],
    },

    'codelab_css': {
      'module_id': 2,
      'title': 'CSS Styling Mastery',
      'level': 'Beginner',
      'tujuan_pembelajaran': 'Style HTML pages with colors, typography, layouts, animations, and responsive design.',
      'total_slide': 16,
      'materials': [
        {'material_id': 1, 'title': 'What is CSS?', 'content': 'CSS (Cascading Style Sheets) controls the visual presentation of HTML elements. It separates content (HTML) from presentation (CSS), making websites maintainable. CSS rules consist of a selector, properties, and values. Multiple stylesheets can apply to a page, and they "cascade" according to specificity rules.', 'example': '/* Basic CSS rule */\nbody {\n  font-family: Arial, sans-serif;\n  background-color: #f0f0f0;\n  color: #333333;\n}'},
        {'material_id': 2, 'title': 'CSS Selectors', 'content': 'CSS selectors target HTML elements to apply styles. Element selectors target tag names. Class selectors (.) target elements with a specific class. ID selectors (#) target a unique element. Attribute selectors target elements with specific attributes. Pseudo-classes like :hover and :focus add interactivity.', 'example': '/* Different selector types */\np { color: blue; }          /* element */\n.highlight { background: yellow; }  /* class */\n#header { font-size: 24px; }  /* ID */\na:hover { color: red; }      /* pseudo-class */\ninput[type="email"] { border: 2px solid blue; } /* attribute */'},
        {'material_id': 3, 'title': 'Colors & Backgrounds', 'content': 'CSS supports multiple color formats: named colors, hexadecimal (#RRGGBB), RGB, RGBA (with transparency), HSL, and HSLA. Background properties control the background color, image, size, position, and repeat behavior. Gradients (linear-gradient, radial-gradient) create smooth color transitions.', 'example': '.card {\n  color: #2D3748;                     /* hex */\n  background-color: rgba(255,255,255,0.9); /* rgba */\n  background: linear-gradient(135deg, #667eea, #764ba2);\n  border: 1px solid hsl(220, 14%, 96%);\n}'},
        {'material_id': 4, 'title': 'Typography & Fonts', 'content': 'Typography significantly impacts readability and design quality. CSS font properties include font-family, font-size, font-weight, font-style, and line-height. The @font-face rule loads custom fonts. Google Fonts provides hundreds of free web fonts via a simple link tag. Text properties control alignment, decoration, spacing, and transformation.', 'example': '@import url("https://fonts.googleapis.com/css2?family=Inter:wght@400;700&display=swap");\n\nbody {\n  font-family: "Inter", sans-serif;\n  font-size: 16px;\n  line-height: 1.6;\n  letter-spacing: 0.02em;\n}\n\nh1 { font-weight: 700; font-size: 2rem; }'},
        {'material_id': 5, 'title': 'The CSS Box Model', 'content': 'Every HTML element is a rectangular box with four layers: content (the actual text/image), padding (space inside the border), border (a line around the padding), and margin (space outside the border). The box-sizing property (border-box) includes padding and border in the element\'s total size, making layout calculations intuitive.', 'example': '.card {\n  width: 300px;\n  padding: 20px;\n  border: 2px solid #e2e8f0;\n  margin: 16px;\n  border-radius: 12px;\n  box-sizing: border-box; /* width includes padding + border */\n}'},
        {'material_id': 6, 'title': 'CSS Positioning', 'content': 'The position property controls how elements are placed in the document. Static (default) follows normal flow. Relative moves an element relative to its normal position. Absolute positions relative to the nearest positioned ancestor. Fixed stays in a fixed position on screen. Sticky combines relative and fixed behavior.', 'example': '.navbar {\n  position: sticky;\n  top: 0;           /* sticks to top when scrolling */\n  z-index: 100;\n}\n\n.badge {\n  position: absolute;\n  top: -8px;\n  right: -8px;     /* positioned relative to parent */\n}'},
        {'material_id': 7, 'title': 'Flexbox Layout', 'content': 'Flexbox is a powerful one-dimensional layout system for arranging items in rows or columns. The parent container uses display: flex. justify-content controls alignment on the main axis. align-items controls alignment on the cross axis. flex-wrap allows items to wrap to new lines. The flex shorthand on children controls growth, shrinking, and base size.', 'example': '.container {\n  display: flex;\n  justify-content: space-between;\n  align-items: center;\n  gap: 16px;\n  flex-wrap: wrap;\n}\n\n.item { flex: 1 1 200px; } /* grow, shrink, base size */'},
        {'material_id': 8, 'title': 'CSS Grid Layout', 'content': 'CSS Grid is a two-dimensional layout system for creating complex page layouts. The parent uses display: grid. grid-template-columns and grid-template-rows define the grid structure. The fr unit distributes available space proportionally. Items can span multiple cells with grid-column and grid-row. The gap property sets spacing between cells.', 'example': '.grid {\n  display: grid;\n  grid-template-columns: repeat(3, 1fr);\n  grid-template-rows: auto;\n  gap: 20px;\n}\n\n.featured {\n  grid-column: span 2; /* takes 2 columns */\n  grid-row: span 2;    /* takes 2 rows */\n}'},
        {'material_id': 9, 'title': 'CSS Transitions', 'content': 'Transitions create smooth animations when CSS properties change. The transition shorthand specifies which properties to animate, their duration, timing function, and delay. Common timing functions include ease, linear, ease-in, ease-out, and ease-in-out. Transitions are typically triggered by state changes like :hover.', 'example': '.button {\n  background-color: #4299e1;\n  transform: translateY(0);\n  box-shadow: 0 4px 6px rgba(0,0,0,0.1);\n  transition: all 0.3s ease;\n}\n\n.button:hover {\n  background-color: #2b6cb0;\n  transform: translateY(-2px);\n  box-shadow: 0 8px 15px rgba(0,0,0,0.2);\n}'},
        {'material_id': 10, 'title': 'CSS Animations', 'content': 'CSS animations provide more control than transitions. @keyframes defines the animation sequence with from/to or percentage-based steps. The animation property applies the keyframes and controls duration, timing, delay, iteration count, and fill mode. Animations can run automatically without user interaction.', 'example': '@keyframes fadeInUp {\n  from {\n    opacity: 0;\n    transform: translateY(20px);\n  }\n  to {\n    opacity: 1;\n    transform: translateY(0);\n  }\n}\n\n.card {\n  animation: fadeInUp 0.5s ease-out forwards;\n}'},
        {'material_id': 11, 'title': 'Responsive Design Basics', 'content': 'Responsive design ensures websites look great on all devices. Key techniques include fluid layouts (using percentages instead of fixed widths), flexible images (max-width: 100%), and media queries. The mobile-first approach starts with styles for small screens and progressively enhances for larger ones.', 'example': '/* Mobile-first approach */\n.container { padding: 16px; }\n\n/* Tablet */\n@media (min-width: 768px) {\n  .container { padding: 24px; }\n  .grid { display: grid; grid-template-columns: 1fr 1fr; }\n}\n\n/* Desktop */\n@media (min-width: 1024px) {\n  .container { max-width: 1200px; margin: 0 auto; }\n}'},
        {'material_id': 12, 'title': 'CSS Variables (Custom Properties)', 'content': 'CSS Custom Properties (variables) allow you to define reusable values. They are defined with -- prefix and accessed with var(). Defined in :root, they are globally available. They enable consistent theming, and can even be changed with JavaScript. They cascade and inherit like regular CSS properties.', 'example': ':root {\n  --primary: #4299e1;\n  --text: #2d3748;\n  --radius: 12px;\n  --spacing: 16px;\n}\n\n.button {\n  background: var(--primary);\n  border-radius: var(--radius);\n  padding: var(--spacing);\n  color: white;\n}'},
        {'material_id': 13, 'title': 'CSS Specificity & Cascade', 'content': 'When multiple CSS rules target the same element, the cascade determines which one wins. Specificity is calculated based on selector type: inline styles > ID selectors > class/attribute/pseudo-class selectors > element selectors. !important overrides everything but should be used sparingly. Source order (last rule wins) is the tiebreaker.', 'example': '/* Specificity: 0-0-1 (element) */\np { color: blue; }\n\n/* Specificity: 0-1-0 (class) — wins over element */\n.text { color: green; }\n\n/* Specificity: 1-0-0 (ID) — wins over class */\n#main-text { color: red; }\n\n/* !important — overrides everything (use sparingly) */\n.override { color: purple !important; }'},
        {'material_id': 14, 'title': 'CSS Pseudo-elements', 'content': 'Pseudo-elements create virtual elements that can be styled. ::before and ::after insert generated content before or after an element\'s content. ::first-letter and ::first-line style parts of text. ::placeholder styles form input placeholders. ::selection styles text selected by the user. They require the content property (even if empty).', 'example': '.card::before {\n  content: "";\n  display: block;\n  width: 4px;\n  height: 100%;\n  background: var(--primary);\n  position: absolute;\n  left: 0;\n}\n\n.quote::first-letter {\n  font-size: 3rem;\n  font-weight: bold;\n  float: left;\n}'},
        {'material_id': 15, 'title': 'CSS Frameworks Overview', 'content': 'CSS frameworks provide pre-built components and utility classes that speed up development. Popular frameworks include Bootstrap (component-based), Tailwind CSS (utility-first), and Bulma. Understanding raw CSS makes it easier to use frameworks effectively and customise them. Frameworks are tools that supplement, not replace, CSS knowledge.', 'example': '/* Tailwind utility approach */\n<button class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">\n  Button\n</button>\n\n/* vs pure CSS */\n.button {\n  background-color: #3b82f6;\n  color: white;\n  font-weight: bold;\n  padding: 8px 16px;\n  border-radius: 4px;\n}'},
        {'material_id': 16, 'title': 'CSS Project: Complete Styling', 'content': 'Putting it all together! A professional CSS implementation combines: a design system with CSS variables, responsive grid layouts, Flexbox for component alignment, smooth transitions and animations, accessible focus styles, and utility classes. This lesson walks through styling a complete card component from scratch.', 'example': ':root {\n  --primary: #6366f1;\n  --radius-lg: 16px;\n}\n\n.card {\n  background: white;\n  border-radius: var(--radius-lg);\n  box-shadow: 0 4px 6px rgba(0,0,0,.07);\n  overflow: hidden;\n  transition: transform 0.2s ease, box-shadow 0.2s ease;\n}\n\n.card:hover {\n  transform: translateY(-4px);\n  box-shadow: 0 12px 24px rgba(0,0,0,.12);\n}'},
      ],
    },

    'codelab_python': {
      'module_id': 3,
      'title': 'Python Programming',
      'level': 'Beginner',
      'tujuan_pembelajaran': 'Master Python from variables to object-oriented programming and file handling.',
      'total_slide': 16,
      'materials': [
        {'material_id': 1, 'title': 'Introduction to Python', 'content': 'Python is a high-level, interpreted programming language known for its readability and simplicity. Created by Guido van Rossum in 1991, it is now one of the most popular languages in the world, used in web development, data science, AI, automation, and more. Python\'s philosophy emphasizes code readability and simplicity.', 'example': '# Your first Python program\nprint("Hello, LearnNova!")\n\n# Variables do not need type declarations\nname = "Student"\nage = 20\nprint(f"Welcome, {name}! You are {age} years old.")'},
        {'material_id': 2, 'title': 'Variables & Data Types', 'content': 'Python has several built-in data types. Integers (int) are whole numbers. Floats are decimal numbers. Strings (str) are text in quotes. Booleans (bool) are True or False. Python uses dynamic typing — the type is determined at runtime. Use type() to check a variable\'s type.', 'example': 'age = 25              # int\nprice = 9.99          # float\nname = "LearnNova"    # str\nis_active = True      # bool\n\nprint(type(age))      # <class "int">\nprint(type(price))    # <class "float">\nprint(type(name))     # <class "str">'},
        {'material_id': 3, 'title': 'Strings & String Methods', 'content': 'Strings are sequences of characters. Python provides rich string manipulation tools. You can use single or double quotes. F-strings (f"") allow embedding expressions. String methods include upper(), lower(), strip(), split(), replace(), and startswith(). Strings support slicing with [start:end:step].', 'example': 'text = "  Hello, World!  "\nprint(text.strip())         # "Hello, World!"\nprint(text.upper())         # "  HELLO, WORLD!  "\nprint(text.replace("World", "Python"))  # "  Hello, Python!  "\n\nname = "LearnNova"\nprint(name[0:5])            # "Learn"\nprint(f"App: {name}")       # "App: LearnNova"'},
        {'material_id': 4, 'title': 'Control Flow — If/Elif/Else', 'content': 'Conditional statements allow your program to make decisions. Python uses if, elif (else if), and else. Indentation (4 spaces) defines code blocks — Python has no curly braces. Comparison operators: ==, !=, <, >, <=, >=. Logical operators: and, or, not. The ternary operator allows one-line conditionals.', 'example': 'score = 85\n\nif score >= 90:\n    grade = "A"\nelif score >= 75:\n    grade = "B"\nelif score >= 60:\n    grade = "C"\nelse:\n    grade = "F"\n\nprint(f"Score: {score}, Grade: {grade}")\n\n# Ternary (one-line)\nstatus = "Pass" if score >= 60 else "Fail"'},
        {'material_id': 5, 'title': 'Loops — For & While', 'content': 'Loops repeat code blocks. The for loop iterates over sequences like lists, strings, and ranges. The while loop repeats while a condition is True. Use break to exit a loop early and continue to skip to the next iteration. The range() function generates number sequences for iteration.', 'example': '# for loop with range\nfor i in range(1, 6):\n    print(f"Lesson {i}")\n\n# Iterating over a list\nfruits = ["apple", "banana", "cherry"]\nfor fruit in fruits:\n    print(fruit.upper())\n\n# while loop\ncount = 0\nwhile count < 3:\n    print(f"Count: {count}")\n    count += 1'},
        {'material_id': 6, 'title': 'Lists', 'content': 'Lists are ordered, mutable sequences that can hold items of any type. They are created with square brackets. Common operations: append() adds an item, remove() deletes by value, pop() removes by index, len() returns the count, and sorted() returns a sorted copy. List comprehensions provide a concise way to create lists.', 'example': 'scores = [85, 92, 78, 96, 61]\n\nscores.append(88)         # add to end\nscores.remove(61)         # remove by value\nhighest = max(scores)     # 96\nlowest = min(scores)      # 78\naverage = sum(scores) / len(scores)\n\n# List comprehension\npassed = [s for s in scores if s >= 75]\nprint(passed)              # [85, 92, 78, 96, 88]'},
        {'material_id': 7, 'title': 'Dictionaries', 'content': 'Dictionaries store key-value pairs. They are created with curly braces. Keys must be unique and immutable (usually strings). Values can be any type. Methods include keys(), values(), items(), get(), update(), and pop(). Dictionaries are commonly used to represent structured data like API responses.', 'example': 'student = {\n    "name": "Ali",\n    "age": 20,\n    "scores": [85, 92, 78],\n    "is_active": True\n}\n\nprint(student["name"])       # "Ali"\nprint(student.get("grade", "N/A"))  # "N/A" (default)\n\nstudent["grade"] = "B"       # add new key\ndel student["is_active"]     # remove key\n\nfor key, value in student.items():\n    print(f"{key}: {value}")'},
        {'material_id': 8, 'title': 'Functions', 'content': 'Functions are reusable blocks of code defined with the def keyword. They can accept parameters and return values using the return statement. Default parameter values allow optional arguments. Functions can return multiple values as a tuple. Docstrings (triple-quoted strings) document what a function does.', 'example': 'def calculate_grade(score, max_score=100):\n    """Calculate letter grade from a numerical score."""\n    percentage = (score / max_score) * 100\n    if percentage >= 90: return "A"\n    elif percentage >= 75: return "B"\n    elif percentage >= 60: return "C"\n    else: return "F"\n\ngrade = calculate_grade(85)   # "B"\nprint(calculate_grade(95, 100))  # "A"'},
        {'material_id': 9, 'title': 'Modules & Imports', 'content': 'Python\'s module system allows you to organise and reuse code. Import statements bring external modules into your script. The standard library provides modules for math, datetime, file I/O, and much more. Third-party packages installed via pip extend Python\'s capabilities enormously.', 'example': 'import math\nimport random\nfrom datetime import datetime\n\nprint(math.sqrt(16))         # 4.0\nprint(math.pi)               # 3.14159...\nprint(random.randint(1, 10)) # random number\n\nnow = datetime.now()\nprint(now.strftime("%Y-%m-%d %H:%M")) # formatted date\n\n# Import specific function\nfrom math import ceil, floor\nprint(ceil(4.3))   # 5\nprint(floor(4.9))  # 4'},
        {'material_id': 10, 'title': 'Error Handling', 'content': 'Errors and exceptions are inevitable in programming. Python\'s try/except blocks allow you to handle errors gracefully instead of crashing. The except clause catches specific exceptions. finally runs code regardless of whether an exception occurred. Raise your own exceptions with the raise statement for better error communication.', 'example': 'def divide(a, b):\n    try:\n        result = a / b\n        return result\n    except ZeroDivisionError:\n        print("Error: Cannot divide by zero!")\n        return None\n    except TypeError as e:\n        print(f"Type error: {e}")\n        return None\n    finally:\n        print("Division operation completed.")\n\nprint(divide(10, 2))   # 5.0\nprint(divide(10, 0))   # Error message'},
        {'material_id': 11, 'title': 'File Handling', 'content': 'Python can read from and write to files using the open() function. The with statement ensures files are properly closed after use. Modes include "r" (read), "w" (write, overwrites), "a" (append), and "b" for binary files. JSON files are commonly used for structured data and Python\'s json module makes them easy to handle.', 'example': 'import json\n\n# Writing JSON\ndata = {"name": "Ali", "score": 95}\nwith open("data.json", "w") as f:\n    json.dump(data, f, indent=2)\n\n# Reading JSON\nwith open("data.json", "r") as f:\n    loaded = json.load(f)\n    print(loaded["name"])  # "Ali"\n\n# Appending text\nwith open("log.txt", "a") as f:\n    f.write("New log entry\\n")'},
        {'material_id': 12, 'title': 'Object-Oriented Programming — Classes', 'content': 'Object-Oriented Programming (OOP) models real-world entities as objects with attributes (data) and methods (behaviour). The class keyword defines a blueprint. The __init__ method initialises new instances. self refers to the current instance. Classes promote code reuse, modularity, and clean architecture.', 'example': 'class Student:\n    def __init__(self, name, age):\n        self.name = name\n        self.age = age\n        self.scores = []\n\n    def add_score(self, score):\n        self.scores.append(score)\n\n    def average(self):\n        return sum(self.scores) / len(self.scores) if self.scores else 0\n\n    def __str__(self):\n        return f"Student: {self.name}"\n\nali = Student("Ali", 20)\nali.add_score(85)\nali.add_score(92)\nprint(ali.average())  # 88.5'},
        {'material_id': 13, 'title': 'Inheritance & Polymorphism', 'content': 'Inheritance allows a class to inherit attributes and methods from a parent class. The child class can override methods to provide specific behaviour. super() calls the parent class methods. Polymorphism allows different classes to be used interchangeably if they share a common interface.', 'example': 'class Animal:\n    def __init__(self, name):\n        self.name = name\n\n    def speak(self):\n        return "Some sound"\n\nclass Dog(Animal):\n    def speak(self):\n        return f"{self.name} says: Woof!"\n\nclass Cat(Animal):\n    def speak(self):\n        return f"{self.name} says: Meow!"\n\nanimals = [Dog("Rex"), Cat("Whiskers")]\nfor animal in animals:\n    print(animal.speak())  # Polymorphism'},
        {'material_id': 14, 'title': 'List Comprehensions & Generators', 'content': 'List comprehensions provide concise ways to create lists. They are more readable and often faster than equivalent for loops. Generator expressions are like list comprehensions but produce items lazily, saving memory. The yield keyword creates generator functions that produce values on demand.', 'example': '# List comprehension\nnumbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]\nevens = [n for n in numbers if n % 2 == 0]\nsquares = [n**2 for n in numbers]\nprint(evens)    # [2, 4, 6, 8, 10]\nprint(squares)  # [1, 4, 9, 16, 25, ...]\n\n# Generator (memory efficient)\ndef fibonacci():\n    a, b = 0, 1\n    while True:\n        yield a\n        a, b = b, a + b\n\nfib = fibonacci()\nprint([next(fib) for _ in range(8)])  # first 8 Fibonacci'},
        {'material_id': 15, 'title': 'Working with APIs', 'content': 'APIs (Application Programming Interfaces) allow programs to communicate with external services. The requests library makes HTTP requests simple in Python. You can GET data, POST data, and handle JSON responses. API keys authenticate requests. Always handle network errors gracefully with try/except.', 'example': 'import requests\n\n# GET request\nresponse = requests.get(\n    "https://api.example.com/users",\n    headers={"Authorization": "Bearer your_token"},\n    timeout=10\n)\n\nif response.status_code == 200:\n    data = response.json()  # parse JSON\n    for user in data["users"]:\n        print(user["name"])\nelse:\n    print(f"Error: {response.status_code}")'},
        {'material_id': 16, 'title': 'Python Project: Build a Data Analyser', 'content': 'Let\'s build a small data analysis script that combines everything you have learned: reading a JSON file, processing data with list comprehensions, computing statistics, using functions, and outputting formatted results. This capstone exercise demonstrates the power of Python for real-world data tasks.', 'example': 'import json, statistics\n\ndef analyse_scores(filename):\n    with open(filename) as f:\n        data = json.load(f)\n\n    scores = [s["score"] for s in data["students"]]\n    passed = [s for s in data["students"] if s["score"] >= 60]\n\n    print(f"Total students: {len(scores)}")\n    print(f"Average score: {statistics.mean(scores):.1f}")\n    print(f"Highest: {max(scores)}, Lowest: {min(scores)}")\n    print(f"Pass rate: {len(passed)/len(scores)*100:.1f}%")\n\nanalyse_scores("results.json")'},
      ],
    },
  };

  // ─── Mock Quiz Data ──────────────────────────────────────────────────────

  static final Map<String, Map<String, dynamic>> _allMockQuizzes = {
    'codelab_html': {
      'module_id': 1,
      'quiz_title': 'HTML Fundamentals — Final Quiz (20 Questions)',
      'questions': [
        {'question_id': 1, 'question': 'What does HTML stand for?', 'options': ['HyperText Markup Language', 'HighText Machine Language', 'Hyper Transfer Machine Language', 'Home Tool Markup Language'], 'correct_answer': 'HyperText Markup Language'},
        {'question_id': 2, 'question': 'Which HTML tag defines the largest heading?', 'options': ['<h6>', '<head>', '<h1>', '<heading>'], 'correct_answer': '<h1>'},
        {'question_id': 3, 'question': 'What is the correct HTML element for inserting a line break?', 'options': ['<break>', '<lb>', '<br>', '<newline>'], 'correct_answer': '<br>'},
        {'question_id': 4, 'question': 'Which attribute makes a link open in a new tab?', 'options': ['target="_blank"', 'open="new"', 'href="new"', 'rel="newtab"'], 'correct_answer': 'target="_blank"'},
        {'question_id': 5, 'question': 'What is the correct HTML for creating a hyperlink?', 'options': ['<a href="url">text</a>', '<link href="url">text</link>', '<a url="url">text</a>', '<url>text</url>'], 'correct_answer': '<a href="url">text</a>'},
        {'question_id': 6, 'question': 'Which attribute provides alternative text for an image?', 'options': ['title', 'src', 'alt', 'description'], 'correct_answer': 'alt'},
        {'question_id': 7, 'question': 'Which HTML element creates an unordered list?', 'options': ['<list>', '<ol>', '<ul>', '<li>'], 'correct_answer': '<ul>'},
        {'question_id': 8, 'question': 'What element is used for a numbered list?', 'options': ['<nl>', '<ul>', '<li>', '<ol>'], 'correct_answer': '<ol>'},
        {'question_id': 9, 'question': 'Which HTML element defines important/bold text?', 'options': ['<bold>', '<b>', '<important>', '<strong>'], 'correct_answer': '<strong>'},
        {'question_id': 10, 'question': 'What attribute specifies where a form\'s data is submitted?', 'options': ['method', 'action', 'submit', 'href'], 'correct_answer': 'action'},
        {'question_id': 11, 'question': 'Which input type creates a clickable button for form submission?', 'options': ['type="button"', 'type="click"', 'type="submit"', 'type="send"'], 'correct_answer': 'type="submit"'},
        {'question_id': 12, 'question': 'What is the purpose of the <meta charset="UTF-8"> tag?', 'options': ['Sets page color', 'Defines character encoding', 'Links a stylesheet', 'Sets page title'], 'correct_answer': 'Defines character encoding'},
        {'question_id': 13, 'question': 'Which semantic HTML5 element wraps the main content of a page?', 'options': ['<content>', '<body>', '<section>', '<main>'], 'correct_answer': '<main>'},
        {'question_id': 14, 'question': 'What does the DOCTYPE declaration tell the browser?', 'options': ['The page author', 'The HTML version being used', 'The page language', 'The page title'], 'correct_answer': 'The HTML version being used'},
        {'question_id': 15, 'question': 'Which element is used to define a table row?', 'options': ['<row>', '<r>', '<td>', '<tr>'], 'correct_answer': '<tr>'},
        {'question_id': 16, 'question': 'What does the "required" attribute do on a form input?', 'options': ['Styles the input', 'Makes the input read-only', 'Prevents form submission if empty', 'Sets a default value'], 'correct_answer': 'Prevents form submission if empty'},
        {'question_id': 17, 'question': 'Which HTML element is used to embed audio?', 'options': ['<sound>', '<media>', '<audio>', '<mp3>'], 'correct_answer': '<audio>'},
        {'question_id': 18, 'question': 'What is the difference between <section> and <div>?', 'options': ['No difference', '<section> is semantic; <div> is generic', '<div> is semantic; <section> is generic', '<section> requires a heading'], 'correct_answer': '<section> is semantic; <div> is generic'},
        {'question_id': 19, 'question': 'Which attribute enables CSS class-based targeting?', 'options': ['id', 'name', 'class', 'style'], 'correct_answer': 'class'},
        {'question_id': 20, 'question': 'Which HTML element defines the navigation links of a website?', 'options': ['<navigate>', '<links>', '<nav>', '<menu>'], 'correct_answer': '<nav>'},
      ],
    },

    'codelab_css': {
      'module_id': 2,
      'quiz_title': 'CSS Styling — Final Quiz (20 Questions)',
      'questions': [
        {'question_id': 1, 'question': 'What does CSS stand for?', 'options': ['Computer Style Sheets', 'Cascading Style Sheets', 'Creative Style Sheets', 'Colorful Style Sheets'], 'correct_answer': 'Cascading Style Sheets'},
        {'question_id': 2, 'question': 'Which CSS property changes text color?', 'options': ['font-color', 'text-color', 'color', 'foreground'], 'correct_answer': 'color'},
        {'question_id': 3, 'question': 'How do you select an element with id="header" in CSS?', 'options': ['.header', '#header', '*header', 'header'], 'correct_answer': '#header'},
        {'question_id': 4, 'question': 'What is the outermost layer of the CSS Box Model?', 'options': ['Content', 'Padding', 'Border', 'Margin'], 'correct_answer': 'Margin'},
        {'question_id': 5, 'question': 'Which CSS value enables Flexbox on a container?', 'options': ['display: block', 'display: flex', 'display: grid', 'display: inline'], 'correct_answer': 'display: flex'},
        {'question_id': 6, 'question': 'Which property aligns flex items along the main axis?', 'options': ['align-items', 'justify-content', 'align-self', 'flex-direction'], 'correct_answer': 'justify-content'},
        {'question_id': 7, 'question': 'What does "display: grid" do?', 'options': ['Creates a table layout', 'Activates CSS Grid on a container', 'Hides an element', 'Aligns items in a row'], 'correct_answer': 'Activates CSS Grid on a container'},
        {'question_id': 8, 'question': 'Which property makes an element stick to the top of the screen when scrolling?', 'options': ['position: fixed', 'position: absolute', 'position: sticky', 'position: relative'], 'correct_answer': 'position: sticky'},
        {'question_id': 9, 'question': 'What CSS at-rule creates smooth property animations?', 'options': ['@media', '@keyframes', '@font-face', '@import'], 'correct_answer': '@keyframes'},
        {'question_id': 10, 'question': 'What is the correct syntax for a CSS variable?', 'options': ['\$primary: blue', 'var-primary: blue', '--primary: blue', '#primary: blue'], 'correct_answer': '--primary: blue'},
        {'question_id': 11, 'question': 'Which CSS unit is relative to the viewport width?', 'options': ['em', 'rem', 'vw', 'px'], 'correct_answer': 'vw'},
        {'question_id': 12, 'question': 'What does "box-sizing: border-box" do?', 'options': ['Adds a border', 'Includes padding and border in element width', 'Removes the box shadow', 'Centers the element'], 'correct_answer': 'Includes padding and border in element width'},
        {'question_id': 13, 'question': 'Which pseudo-class applies styles when hovering over an element?', 'options': [':active', ':focus', ':hover', ':visited'], 'correct_answer': ':hover'},
        {'question_id': 14, 'question': 'What CSS property creates a smooth animation between states?', 'options': ['animation', 'transform', 'transition', 'keyframe'], 'correct_answer': 'transition'},
        {'question_id': 15, 'question': 'What is a media query used for?', 'options': ['Adding media files', 'Styling based on screen size', 'Creating animations', 'Importing fonts'], 'correct_answer': 'Styling based on screen size'},
        {'question_id': 16, 'question': 'Which CSS property controls the stacking order of elements?', 'options': ['layer', 'order', 'z-index', 'stack'], 'correct_answer': 'z-index'},
        {'question_id': 17, 'question': 'What does "fr" mean in CSS Grid?', 'options': ['Fixed ratio', 'Fractional unit', 'Frame rate', 'Full row'], 'correct_answer': 'Fractional unit'},
        {'question_id': 18, 'question': 'Which selector has the highest specificity?', 'options': ['Element selector', 'Class selector', 'ID selector', 'Universal selector (*)'], 'correct_answer': 'ID selector'},
        {'question_id': 19, 'question': 'What does the "::before" pseudo-element do?', 'options': ['Targets the first child', 'Inserts content before the element', 'Styles the first letter', 'Adds a border before the element'], 'correct_answer': 'Inserts content before the element'},
        {'question_id': 20, 'question': 'What CSS property rounds the corners of an element?', 'options': ['corner-radius', 'border-round', 'border-radius', 'rounded'], 'correct_answer': 'border-radius'},
      ],
    },

    'codelab_python': {
      'module_id': 3,
      'quiz_title': 'Python Programming — Final Quiz (20 Questions)',
      'questions': [
        {'question_id': 1, 'question': 'What is the correct syntax to print "Hello" in Python?', 'options': ['echo("Hello")', 'printf("Hello")', 'print("Hello")', 'console.log("Hello")'], 'correct_answer': 'print("Hello")'},
        {'question_id': 2, 'question': 'Which keyword is used to define a function in Python?', 'options': ['func', 'function', 'define', 'def'], 'correct_answer': 'def'},
        {'question_id': 3, 'question': 'What data type stores key-value pairs?', 'options': ['List', 'Tuple', 'Dictionary', 'Set'], 'correct_answer': 'Dictionary'},
        {'question_id': 4, 'question': 'How do you create a list in Python?', 'options': ['(1, 2, 3)', '{1, 2, 3}', '[1, 2, 3]', '<1, 2, 3>'], 'correct_answer': '[1, 2, 3]'},
        {'question_id': 5, 'question': 'What is the output of: print(type(3.14))?', 'options': ['<class "int">', '<class "float">', '<class "str">', '<class "double">'], 'correct_answer': '<class "float">'},
        {'question_id': 6, 'question': 'Which loop keyword exits a loop immediately?', 'options': ['exit', 'stop', 'break', 'return'], 'correct_answer': 'break'},
        {'question_id': 7, 'question': 'What does the range(5) function return?', 'options': ['[0, 1, 2, 3, 4, 5]', 'A range of 0 to 4', 'A range of 1 to 5', '[1, 2, 3, 4, 5]'], 'correct_answer': 'A range of 0 to 4'},
        {'question_id': 8, 'question': 'What is an f-string in Python?', 'options': ['A file string', 'A formatted string literal', 'A function string', 'A float string'], 'correct_answer': 'A formatted string literal'},
        {'question_id': 9, 'question': 'Which method adds an item to the end of a Python list?', 'options': ['add()', 'insert()', 'push()', 'append()'], 'correct_answer': 'append()'},
        {'question_id': 10, 'question': 'What is the keyword used to handle errors in Python?', 'options': ['catch', 'rescue', 'except', 'handle'], 'correct_answer': 'except'},
        {'question_id': 11, 'question': 'Which operator is used for string concatenation in Python?', 'options': ['&', '+', '.', ','], 'correct_answer': '+'},
        {'question_id': 12, 'question': 'What is the purpose of "self" in a Python class method?', 'options': ['Refers to the class itself', 'Refers to the current instance', 'Refers to the parent class', 'Refers to a static method'], 'correct_answer': 'Refers to the current instance'},
        {'question_id': 13, 'question': 'How do you open a file for reading in Python?', 'options': ['open("file.txt", "w")', 'open("file.txt", "r")', 'open("file.txt", "a")', 'read("file.txt")'], 'correct_answer': 'open("file.txt", "r")'},
        {'question_id': 14, 'question': 'What is a Python generator?', 'options': ['A list creator', 'A function that yields values lazily', 'A class constructor', 'A random number producer'], 'correct_answer': 'A function that yields values lazily'},
        {'question_id': 15, 'question': 'What does "inheritance" mean in OOP?', 'options': ['Copying a file', 'A class gaining properties of another class', 'Hiding implementation details', 'Overloading operators'], 'correct_answer': 'A class gaining properties of another class'},
        {'question_id': 16, 'question': 'Which Python module is used for JSON operations?', 'options': ['json', 'pickle', 'csv', 'data'], 'correct_answer': 'json'},
        {'question_id': 17, 'question': 'What is the output of: print(10 // 3)?', 'options': ['3.33', '3', '4', '10/3'], 'correct_answer': '3'},
        {'question_id': 18, 'question': 'What is a list comprehension?', 'options': ['A list summary', 'A concise way to create a list', 'A type of dictionary', 'A method to sort a list'], 'correct_answer': 'A concise way to create a list'},
        {'question_id': 19, 'question': 'What does "import math" do?', 'options': ['Creates a new math module', 'Loads the built-in math module', 'Defines math functions', 'Compiles math code'], 'correct_answer': 'Loads the built-in math module'},
        {'question_id': 20, 'question': 'Which statement is true about Python indentation?', 'options': ['It is optional', 'It defines code blocks', 'It is purely aesthetic', 'It uses curly braces'], 'correct_answer': 'It defines code blocks'},
      ],
    },

    'creative_studio_uiux': {
      'module_id': 4,
      'quiz_title': 'UI/UX Design — Final Quiz (20 Questions)',
      'questions': [
        {'question_id': 1, 'question': 'What does UI stand for?', 'options': ['Universal Input', 'User Interface', 'Unique Interaction', 'User Index'], 'correct_answer': 'User Interface'},
        {'question_id': 2, 'question': 'What does UX stand for?', 'options': ['User Exchange', 'User Experience', 'Unique Extension', 'User Expertise'], 'correct_answer': 'User Experience'},
        {'question_id': 3, 'question': 'Which design principle groups related items together?', 'options': ['Contrast', 'Alignment', 'Proximity', 'Repetition'], 'correct_answer': 'Proximity'},
        {'question_id': 4, 'question': 'What are wireframes used for?', 'options': ['Adding colors', 'Creating low-fidelity layout blueprints', 'Writing code', 'Testing animations'], 'correct_answer': 'Creating low-fidelity layout blueprints'},
        {'question_id': 5, 'question': 'What is a user persona?', 'options': ['A fake user account', 'A fictional user representing a target audience', 'A UI component', 'A color scheme'], 'correct_answer': 'A fictional user representing a target audience'},
        {'question_id': 6, 'question': 'What is the primary goal of UX research?', 'options': ['Creating visuals', 'Understanding user needs and behaviors', 'Writing code', 'Setting color palettes'], 'correct_answer': 'Understanding user needs and behaviors'},
        {'question_id': 7, 'question': 'Which tool is most popular for UI design and prototyping?', 'options': ['Photoshop', 'Figma', 'Excel', 'Notepad'], 'correct_answer': 'Figma'},
        {'question_id': 8, 'question': 'What is a prototype in design?', 'options': ['The final product', 'An interactive simulation of the design', 'A color mockup', 'A text document'], 'correct_answer': 'An interactive simulation of the design'},
        {'question_id': 9, 'question': 'What does "affordance" mean in UI/UX?', 'options': ['The cost of design', 'How intuitive an element is to use', 'The size of a button', 'The loading speed'], 'correct_answer': 'How intuitive an element is to use'},
        {'question_id': 10, 'question': 'What is the rule of "F-pattern" in UX?', 'options': ['Fonts should be consistent', 'Users scan content in an F-shaped pattern', 'Forms should be simple', 'Footer is important'], 'correct_answer': 'Users scan content in an F-shaped pattern'},
        {'question_id': 11, 'question': 'What is "white space" in design?', 'options': ['White background color', 'Empty space around elements', 'Unused screen space', 'All of the above'], 'correct_answer': 'Empty space around elements'},
        {'question_id': 12, 'question': 'What does "A/B testing" mean in UX?', 'options': ['Testing two different designs with users', 'Testing the alphabet in fonts', 'Testing two browsers', 'Testing two colors'], 'correct_answer': 'Testing two different designs with users'},
        {'question_id': 13, 'question': 'What is the minimum contrast ratio recommended for body text (WCAG AA)?', 'options': ['2:1', '3:1', '4.5:1', '7:1'], 'correct_answer': '4.5:1'},
        {'question_id': 14, 'question': 'What is a design system?', 'options': ['A collection of design files', 'A reusable set of components and guidelines', 'A software program', 'A color palette'], 'correct_answer': 'A reusable set of components and guidelines'},
        {'question_id': 15, 'question': 'What does "mobile-first" design mean?', 'options': ['Designing only for mobile', 'Starting design from the mobile view and scaling up', 'Mobile is the last priority', 'Using mobile frameworks'], 'correct_answer': 'Starting design from the mobile view and scaling up'},
        {'question_id': 16, 'question': 'What is "heuristic evaluation" in UX?', 'options': ['User testing with real users', 'Expert review against usability principles', 'Automated testing', 'Statistical analysis'], 'correct_answer': 'Expert review against usability principles'},
        {'question_id': 17, 'question': 'What is the purpose of a "call to action" (CTA)?', 'options': ['Decorate the page', 'Prompt users to take a specific action', 'Show legal information', 'Display the logo'], 'correct_answer': 'Prompt users to take a specific action'},
        {'question_id': 18, 'question': 'What is "information architecture"?', 'options': ['Building physical information centers', 'Organizing and structuring content for usability', 'Designing building blueprints', 'Writing technical documentation'], 'correct_answer': 'Organizing and structuring content for usability'},
        {'question_id': 19, 'question': 'Which color model is used for digital screens?', 'options': ['CMYK', 'Pantone', 'RGB', 'HSB only'], 'correct_answer': 'RGB'},
        {'question_id': 20, 'question': 'What is "user journey mapping"?', 'options': ['Mapping geographic locations', 'Visualizing a user\'s steps and emotions through an experience', 'Creating a sitemap', 'Drawing wireframes'], 'correct_answer': 'Visualizing a user\'s steps and emotions through an experience'},
      ],
    },

    'bizlab_marketing': {
      'module_id': 5,
      'quiz_title': 'Digital Marketing — Final Quiz (20 Questions)',
      'questions': [
        {'question_id': 1, 'question': 'What does SEO stand for?', 'options': ['Social Engagement Optimization', 'Search Engine Optimization', 'Sales Enhancement Online', 'Site Exposure Operation'], 'correct_answer': 'Search Engine Optimization'},
        {'question_id': 2, 'question': 'What does CTR measure?', 'options': ['Cost to Run', 'Click-Through Rate', 'Content Tracking Ratio', 'Customer Trust Rating'], 'correct_answer': 'Click-Through Rate'},
        {'question_id': 3, 'question': 'Which platform is best known for professional networking?', 'options': ['TikTok', 'Instagram', 'LinkedIn', 'Snapchat'], 'correct_answer': 'LinkedIn'},
        {'question_id': 4, 'question': 'What does ROI stand for?', 'options': ['Rate of Interest', 'Return on Investment', 'Revenue Optimization Index', 'Reach of Influence'], 'correct_answer': 'Return on Investment'},
        {'question_id': 5, 'question': 'What is "organic reach" in social media?', 'options': ['Paid advertising reach', 'Free, non-paid content visibility', 'Sponsored post performance', 'Influencer reach'], 'correct_answer': 'Free, non-paid content visibility'},
        {'question_id': 6, 'question': 'What is a "conversion" in digital marketing?', 'options': ['Changing your ad creative', 'A user completing a desired action', 'Converting currency', 'A social media like'], 'correct_answer': 'A user completing a desired action'},
        {'question_id': 7, 'question': 'What does SEM stand for?', 'options': ['Social Email Marketing', 'Search Engine Marketing', 'Site Engagement Metrics', 'Social Engagement Management'], 'correct_answer': 'Search Engine Marketing'},
        {'question_id': 8, 'question': 'What is content marketing?', 'options': ['Advertising products directly', 'Creating valuable content to attract and retain audiences', 'Managing social media accounts', 'Email campaigns'], 'correct_answer': 'Creating valuable content to attract and retain audiences'},
        {'question_id': 9, 'question': 'What is a "buyer persona"?', 'options': ['A fake buyer account', 'A fictional representation of an ideal customer', 'A sales contract', 'A marketing team member'], 'correct_answer': 'A fictional representation of an ideal customer'},
        {'question_id': 10, 'question': 'Which metric indicates how many unique users saw your content?', 'options': ['Impressions', 'Reach', 'Engagement', 'Conversions'], 'correct_answer': 'Reach'},
        {'question_id': 11, 'question': 'What is "retargeting" in digital advertising?', 'options': ['Changing your target market', 'Showing ads to users who previously visited your site', 'Targeting a new audience', 'Adjusting your campaign budget'], 'correct_answer': 'Showing ads to users who previously visited your site'},
        {'question_id': 12, 'question': 'What is the "sales funnel"?', 'options': ['A tool for data collection', 'A visual representation of the customer journey', 'A social media strategy', 'An email marketing tool'], 'correct_answer': 'A visual representation of the customer journey'},
        {'question_id': 13, 'question': 'What does CPA stand for?', 'options': ['Content Per Action', 'Cost Per Acquisition', 'Click Per Ad', 'Campaign Performance Analysis'], 'correct_answer': 'Cost Per Acquisition'},
        {'question_id': 14, 'question': 'Which type of content typically gets the highest engagement?', 'options': ['Long text posts', 'Video content', 'Text-only ads', 'Banner ads'], 'correct_answer': 'Video content'},
        {'question_id': 15, 'question': 'What is "email list segmentation"?', 'options': ['Deleting inactive subscribers', 'Dividing your email list into groups for targeted messaging', 'Sending emails at different times', 'Using different email platforms'], 'correct_answer': 'Dividing your email list into groups for targeted messaging'},
        {'question_id': 16, 'question': 'What is "brand awareness"?', 'options': ['The cost of your brand', 'How familiar consumers are with your brand', 'Brand legal registration', 'Number of brand employees'], 'correct_answer': 'How familiar consumers are with your brand'},
        {'question_id': 17, 'question': 'What is "inbound marketing"?', 'options': ['Cold calling and outreach', 'Attracting customers through valuable content', 'TV advertising', 'Direct mail campaigns'], 'correct_answer': 'Attracting customers through valuable content'},
        {'question_id': 18, 'question': 'Which Google tool helps you research keyword popularity?', 'options': ['Google Analytics', 'Google Keyword Planner', 'Google Search Console', 'Google Trends'], 'correct_answer': 'Google Keyword Planner'},
        {'question_id': 19, 'question': 'What is "influencer marketing"?', 'options': ['Hiring celebrities for TV ads', 'Partnering with influential individuals to promote products', 'Using AI to market products', 'Marketing to business executives'], 'correct_answer': 'Partnering with influential individuals to promote products'},
        {'question_id': 20, 'question': 'What does "bounce rate" measure?', 'options': ['How fast your site loads', 'Percentage of visitors who leave after viewing only one page', 'Email open rates', 'Mobile usage percentage'], 'correct_answer': 'Percentage of visitors who leave after viewing only one page'},
      ],
    },
  };
}
