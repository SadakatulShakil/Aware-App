import 'package:aware/features/incident_report/data/models/icident_data_model.dart';

/// Hardcoded demo data — swap this for a repository/API call later.
final List<IncidentDataModel> demoIncidents = [
  const IncidentDataModel(
    userName: 'Md. Al-Amin',
    name: 'Flash Flood Alert',
    location: 'Sylhet Sadar, Sylhet',
    deathCount: 2,
    injuredCount: 5,
    description:
    'Heavy rainfall over the last 24 hours has caused flash flooding in low-lying '
        'areas near the Surma river. Local authorities have opened emergency shelters.',
  ),
  const IncidentDataModel(
    userName: 'Md. Ashioq Uddin',
    name: 'Landslide Warning',
    location: 'Rangamati Sadar, Rangamati',
    deathCount: 0,
    injuredCount: 3,
    description:
    'Continuous rain has increased landslide risk in hilly areas. Residents in '
        'vulnerable zones have been advised to relocate to safer ground temporarily.',
  ),
  const IncidentDataModel(
    userName: 'Abdullah Al Mamun',
    name: 'River Erosion Incident',
    location: 'Chilmari, Kurigram',
    deathCount: 0,
    injuredCount: 0,
    description:
    'Rapid riverbank erosion has affected several homesteads along the Brahmaputra. '
        'Survey teams are assessing the extent of damage and relocation needs.',
  ),
];