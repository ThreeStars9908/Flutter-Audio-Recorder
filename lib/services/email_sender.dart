import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class EmailSender {
  static Future<void> sendEmail(
      String recipientEmail,
      String subject,
      String body,
      List<String> attachmentPaths,
      BuildContext context,
      ) async {
    final Email email = Email(
      body: body,
      subject: subject,
      recipients: [recipientEmail],
      attachmentPaths: attachmentPaths,
      isHTML: false,
    );

    String platformResponse;
    try {
      await FlutterEmailSender.send(email);
      platformResponse = 'success';
    } catch (error) {
      print(error);
      platformResponse = error.toString();
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(platformResponse),
        ),
      );
    }
  }
}