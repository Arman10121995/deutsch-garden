import 'civics_test.dart';
import 'driving_test.dart';
import 'l10n/app_localizations.dart';

String civicsOutcomeText(
  AppText t,
  CivicsTestKind kind,
  CivicsTestResult result,
) => result.passed(kind)
    ? t.civicsPassReached(kind.label)
    : t.civicsPassNotReached(kind.label);

String drivingCategoryText(
  AppText t,
  DrivingQuestionCategory category,
) => switch (category) {
  DrivingQuestionCategory.danger => t.drivingCategoryDanger,
  DrivingQuestionCategory.speedAndDistance => t.drivingCategorySpeedAndDistance,
  DrivingQuestionCategory.rightOfWay => t.drivingCategoryRightOfWay,
  DrivingQuestionCategory.signsAndMarkings => t.drivingCategorySignsAndMarkings,
  DrivingQuestionCategory.motorway => t.drivingCategoryMotorway,
  DrivingQuestionCategory.vulnerableRoadUsers =>
    t.drivingCategoryVulnerableRoadUsers,
  DrivingQuestionCategory.vehicleTechnology =>
    t.drivingCategoryVehicleTechnology,
  DrivingQuestionCategory.fitnessAndEnvironment =>
    t.drivingCategoryFitnessAndEnvironment,
};
