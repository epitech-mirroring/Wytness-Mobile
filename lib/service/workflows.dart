import 'package:mobile/model/workflows.module.dart';

class WorkflowService {
  final List<WorkflowModel> _workflows = [];

  void createWorkflow(WorkflowModel workflow) {
    if (_workflows.contains(workflow)) {
      _workflows.removeWhere((w) => w.uuid == workflow.uuid);
      _workflows.add(workflow);
      return;
    }
    _workflows.add(workflow);
  }

  bool deleteWorkflow(String name) {
    final workflow = _workflows.firstWhere(
      (w) => w.name == name,
    );

    _workflows.remove(workflow);
    return true;
  }

  List<WorkflowModel> get workflows => List.unmodifiable(_workflows);

  set workflows(List<WorkflowModel> workflows) {
    _workflows
      ..clear()
      ..addAll(workflows);
  }

  WorkflowModel? findWorkflowByName(String name) {
    return _workflows.firstWhere(
      (workflow) => workflow.name == name,
    );
  }
}
