import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/workflows.module.dart';
import 'package:mobile/pages/home.dart';
import 'package:mobile/pages/workflow.dart';
import 'package:mobile/service/workflows.service.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('HomePage Widget Tests', () {
    late WorkflowService workflowService;

    setUp(() {
      // Set up a WorkflowService instance with mock data
      workflowService = WorkflowService();
      workflowService.createWorkflow(
        WorkflowModel(
          name: 'Test Workflow',
          description: 'This is a test workflow',
          apis: [],
          uuid: const Uuid().v4(),
        ),
      );
    });

    testWidgets('FloatingActionButton navigates to WorkflowPage',
        (WidgetTester tester) async {
      // Build the HomePage widget with the mock service
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(workflow: workflowService),
        ),
      );

      // Verify the FAB exists
      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);

      // Tap the FAB
      await tester.tap(fabFinder);
      await tester.pumpAndSettle();

      // Verify the navigation to WorkflowPage
      expect(find.byType(WorkflowPage), findsOneWidget);
    });

    testWidgets('Slidable delete action removes workflow',
        (WidgetTester tester) async {
      // Build the HomePage widget with the mock service
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(workflow: workflowService),
        ),
      );

      // Verify the workflow is present
      final workflowFinder = find.text('Test Workflow');
      expect(workflowFinder, findsOneWidget);

      // Swipe to reveal the SlidableAction
      await tester.drag(workflowFinder, const Offset(-200, 0));
      await tester.pumpAndSettle();

      // Tap the delete SlidableAction
      final deleteActionFinder = find.text('Delete');
      expect(deleteActionFinder, findsOneWidget);

      await tester.tap(deleteActionFinder);
      await tester.pumpAndSettle();

      // Verify the workflow is deleted
      expect(workflowFinder, findsNothing);
    });
  });
}
