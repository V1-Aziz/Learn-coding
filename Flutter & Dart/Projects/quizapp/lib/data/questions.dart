import 'package:quizapp/models/quiz_questions.dart';

const questions = [
  Questions("What are the main build block of Flutter UI's?", [
    'Widegts',
    'Components',
    'Blocks',
    'Functions',
  ]),
  Questions("How are Flutter UI's build?", [
    "By combining widgets in code",
    "By combining widgets in visual editor",
    "By defining widgets in config files",
    "By using Xcode for IOS and Android studio for Android",
  ]),
  Questions("Whst's the purpose of a StatefulWidgets?", [
    "Update UI as data changes",
    "Update data as UI changes",
    "Ignoare dara changes",
    "Render UI that does not depand on data",
  ]),
  Questions("What happenes if you changed data in a StatlessWidget?", [
    "The UI is not updated",
    "The UI is Updated",
    "The closet StatefulWidget is updated",
    "Any nested StatefulWidget are updated",
  ]),
  Questions(
    "Which widget should you try to use more often: StatelessWidget or StatefulWidget?",
    [
      "StatelessWidget",
      "StatefulWidget",
      "Both are equally good",
      "None of the above",
    ],
  ),
  Questions("How should you update data inside of StatefulWidget??", [
    "By calling setState()",
    "By calling updateData()",
    "By calling updateUI()",
    "By calling UpdateState()",
  ]),
];
