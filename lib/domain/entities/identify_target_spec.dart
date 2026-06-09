enum IdentifyTargetType { node, edge }

class IdentifyTargetSpec {
  final String prompt;
  final IdentifyTargetType targetType;
  final Set<String> correctTargetIds;
  final bool allowMultiple;

  const IdentifyTargetSpec({
    required this.prompt,
    required this.targetType,
    required this.correctTargetIds,
    this.allowMultiple = false,
  }) : assert(
         correctTargetIds.length > 0,
         'Identify target challenges require at least one correct target.',
       );

  bool get isSingleTarget => !allowMultiple;
}
