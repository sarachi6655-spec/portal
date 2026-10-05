import '../../../../core/constants/api_constants.dart';

class SubServiceItem {
  final String id;
  final String name;
  final String price;
  final String? code;
  final String? turnaroundTime;
  final String? sampleType;
  final String? description;

  const SubServiceItem({
    required this.id,
    required this.name,
    required this.price,
    this.code,
    this.turnaroundTime,
    this.sampleType,
    this.description,
  });

  factory SubServiceItem.fromJson(Map<String, dynamic> json) {
    return SubServiceItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      code: json['code']?.toString(),
      turnaroundTime: json['turnaroundTime']?.toString(),
      sampleType: json['sampleType']?.toString(),
      description: json['description']?.toString(),
    );
  }

  factory SubServiceItem.fromClientServiceTestJson(
    Map<String, dynamic> json, {
    String currency = 'INR',
  }) {
    final code = json['code']?.toString() ?? '';
    final name = json['testName']?.toString() ?? '';
    final rawPrice = json['testPrice'];
    String formattedPrice = '';
    if (rawPrice != null) {
      final numPrice = num.tryParse(rawPrice.toString()) ?? 0;
      final symbol = currency.toUpperCase() == 'INR' ? '₹' : (currency.toUpperCase() == 'USD' ? '\$' : '$currency ');
      formattedPrice = '$symbol${numPrice.toStringAsFixed(2)}';
    }

    return SubServiceItem(
      id: code,
      name: name,
      price: formattedPrice,
      code: code,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'code': code,
        'turnaroundTime': turnaroundTime,
        'sampleType': sampleType,
        'description': description,
      };
}

class ServiceItemDetail {
  final String id;
  final String title;
  final String description;
  final String imagePath;
  final String category;
  final String? startingPrice;
  final String? remarks;

  final List<SubServiceItem> subServices;

  const ServiceItemDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.category,
    this.startingPrice,
    this.remarks,
    this.subServices = const [],
  });

  factory ServiceItemDetail.fromJson(Map<String, dynamic> json) {
    var rawSubServices = json['subServices'] as List<dynamic>? ?? [];
    List<SubServiceItem> subServicesList = rawSubServices.map((item) => SubServiceItem.fromJson(item as Map<String, dynamic>)).toList();

    return ServiceItemDetail(id: json['id']?.toString() ?? '', title: json['title']?.toString() ?? '', description: json['description']?.toString() ?? '', imagePath: json['imagePath']?.toString() ?? '', category: json['category']?.toString() ?? 'General', startingPrice: json['startingPrice']?.toString(), subServices: subServicesList, remarks: json['remarks']?.toString());
  }

  factory ServiceItemDetail.fromClientServiceJson(Map<String, dynamic> json) {
    final code = json['code']?.toString() ?? '';
    final name = json['name']?.toString() ?? '';
    final currency = json['stdQuoteCurrency']?.toString() ?? 'INR';
    final rawQuote = json['stdQuoteValue'];
    final remarks = json['remarks'];
    String? formattedPrice;
    if (rawQuote != null) {
      final numQuote = num.tryParse(rawQuote.toString()) ?? 0;
      final symbol = currency.toUpperCase() == 'INR' ? '₹' : (currency.toUpperCase() == 'USD' ? '\$' : '$currency ');
      formattedPrice = '$symbol${numQuote.toStringAsFixed(2)}';
    }

    final filePath = json['filePath']?.toString() ?? '';
    final fileName = json['fileName']?.toString() ?? '';
    String imagePath = '';
    if (fileName.isNotEmpty && filePath.isNotEmpty) {
      final cleanPath = filePath.split('/').map(Uri.encodeComponent).join('/');
      final cleanFile = Uri.encodeComponent(fileName);
      imagePath = '${ApiConstants.attachmentBaseUrl}$cleanPath/$cleanFile';
    } else {
      imagePath = angioplastyImageUrl;
    }

    final rawTests = json['testLists'] as List<dynamic>? ?? [];
    final tests = rawTests
        .map((t) => SubServiceItem.fromClientServiceTestJson(
              t as Map<String, dynamic>,
              currency: currency,
            ))
        .toList();

    return ServiceItemDetail(id: code, title: name, description: json['description']?.toString() ?? '', imagePath: imagePath, category: '', startingPrice: formattedPrice, subServices: tests, remarks: remarks);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'imagePath': imagePath,
        'category': category,
        'startingPrice': startingPrice,
        'remarks': remarks,
        'subServices': subServices.map((e) => e.toJson()).toList(),
      };

  static const String angioplastyImageUrl = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTIq5w31t9v0_blq0zV-8JY39hgjrxm7TiDOpcuunvQvg&s=10';
  static const String cardiologyImageUrl = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSpcHxRjWZkj9u3GENQ-dm2grZ0c21dYhXJZWnSlVerSw&s=10';
  static const String dentalImageUrl = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQUm54yI7Y4CwgEEGGsDSTob4gwjw1lw5l8Iv5XWnDXGA&s=10';

  /// Out-of-the-box sample catalog for instant running and testing with real images
  static List<ServiceItemDetail> get sampleServices => const [
        ServiceItemDetail(
          id: 'srv_1',
          title: 'Cardiology Services',
          description: 'Comprehensive non-invasive & clinical cardiac diagnostic evaluations, 2D echocardiography, stress testing, and preventative heart care.',
          imagePath: cardiologyImageUrl,
          category: 'Cardiology',
          startingPrice: '\$45.00',
          subServices: [
            SubServiceItem(
              id: 'sub_1_1',
              name: '2D Echocardiography with Color Doppler',
              price: '\$120.00',
              code: 'CARD-101',
              turnaroundTime: 'Same Day',
              sampleType: 'Clinical Ultrasound',
              description: 'Detailed structural imaging of heart chambers, valves, and ventricular ejection fraction.',
            ),
            SubServiceItem(
              id: 'sub_1_2',
              name: 'Treadmill Exercise Stress Test (TMT)',
              price: '\$85.00',
              code: 'CARD-102',
              turnaroundTime: '2 Hours',
              sampleType: 'Physical Stress Test',
              description: 'Monitors inducible coronary ischemia and exercise capacity under standard Bruce protocol.',
            ),
            SubServiceItem(
              id: 'sub_1_3',
              name: '24-Hour Ambulatory Holter ECG Monitoring',
              price: '\$110.00',
              code: 'CARD-103',
              turnaroundTime: '24 Hours',
              sampleType: 'Continuous ECG',
              description: 'Detects transient cardiac arrhythmias, bradycardia, and paroxysmal atrial fibrillation.',
            ),
            SubServiceItem(
              id: 'sub_1_4',
              name: 'Standard 12-Lead Electrocardiogram (ECG)',
              price: '\$25.00',
              code: 'CARD-104',
              turnaroundTime: '30 Minutes',
              sampleType: 'Surface Leads',
              description: 'Baseline resting evaluation of cardiac rhythm, conduction intervals, and infarct patterns.',
            ),
            SubServiceItem(
              id: 'sub_1_5',
              name: 'Coronary CT Angiography & Calcium Score',
              price: '\$280.00',
              code: 'CARD-105',
              turnaroundTime: '24 Hours',
              sampleType: 'Non-Invasive CT',
              description: 'Quantifies coronary artery calcification and high-risk plaque stenosis.',
            ),
          ],
        ),
        ServiceItemDetail(
          id: 'srv_2',
          title: 'Angioplasty Services',
          description: 'Interventional vascular catheterization, balloon coronary angioplasty, bioresorbable and drug-eluting stent placement.',
          imagePath: angioplastyImageUrl,
          category: 'Cardiovascular',
          startingPrice: '\$350.00',
          subServices: [
            SubServiceItem(
              id: 'sub_2_1',
              name: 'Coronary Angioplasty (PTCA with Drug-Eluting Stent)',
              price: '\$1,450.00',
              code: 'ANG-201',
              turnaroundTime: 'Procedure Day',
              sampleType: 'Cath Lab Intervention',
              description: 'Minimally invasive percutaneous transluminal angioplasty to restore coronary blood flow.',
            ),
            SubServiceItem(
              id: 'sub_2_2',
              name: 'Balloon Catheter Angioplasty & Dilation',
              price: '\$850.00',
              code: 'ANG-202',
              turnaroundTime: 'Procedure Day',
              sampleType: 'Catheter Dilation',
              description: 'Balloon expansion to widen narrowed arteries without foreign body implantation.',
            ),
            SubServiceItem(
              id: 'sub_2_3',
              name: 'Fractional Flow Reserve (FFR) Lesion Assessment',
              price: '\$320.00',
              code: 'ANG-203',
              turnaroundTime: 'Intra-Operative',
              sampleType: 'Pressure Wire',
              description: 'Physiological pressure gradient measurement to determine lesion significance.',
            ),
            SubServiceItem(
              id: 'sub_2_4',
              name: 'Intravascular Ultrasound (IVUS) Vascular Imaging',
              price: '\$450.00',
              code: 'ANG-204',
              turnaroundTime: 'Intra-Operative',
              sampleType: 'Intracoronary Ultrasound',
              description: 'High-definition cross-sectional arterial visualization for optimal stent sizing.',
            ),
            SubServiceItem(
              id: 'sub_2_5',
              name: 'Rotational Atherectomy (Rotablation)',
              price: '\$1,100.00',
              code: 'ANG-205',
              turnaroundTime: 'Procedure Day',
              sampleType: 'Diamond Burr Atherectomy',
              description: 'Debulking of heavily calcified coronary lesions prior to stent deployment.',
            ),
          ],
        ),
        ServiceItemDetail(
          id: 'srv_3',
          title: 'Dental Services',
          description: 'Advanced general and specialized dentistry, root canal treatments, implants, cosmetic smile design, and periodontics.',
          imagePath: dentalImageUrl,
          category: 'Dental',
          startingPrice: '\$35.00',
          subServices: [
            SubServiceItem(
              id: 'sub_3_1',
              name: 'Single-Sitting Rotary Root Canal Therapy (RCT)',
              price: '\$160.00',
              code: 'DEN-301',
              turnaroundTime: '1 - 2 Hours',
              sampleType: 'Endodontic Procedure',
              description: 'Painless endodontic cleaning and biocompatible obturation under digital radiography.',
            ),
            SubServiceItem(
              id: 'sub_3_2',
              name: 'Titanium Dental Implant & Zirconia Crown',
              price: '\$650.00',
              code: 'DEN-302',
              turnaroundTime: 'Multi-Stage',
              sampleType: 'Surgical Implant',
              description: 'Permanent biological tooth replacement with grade-V titanium fixture and crown.',
            ),
            SubServiceItem(
              id: 'sub_3_3',
              name: 'Ultrasonic Teeth Scaling & Root Planing',
              price: '\$60.00',
              code: 'DEN-303',
              turnaroundTime: '45 Minutes',
              sampleType: 'Prophylaxis',
              description: 'Deep removal of subgingival calculus, tartar, and plaque deposits.',
            ),
            SubServiceItem(
              id: 'sub_3_4',
              name: 'Laser Teeth Whitening & Aesthetic Restoration',
              price: '\$180.00',
              code: 'DEN-304',
              turnaroundTime: '1 Hour',
              sampleType: 'Cosmetic Dentistry',
              description: 'In-office peroxide photo-activation to lighten shades safely.',
            ),
            SubServiceItem(
              id: 'sub_3_5',
              name: 'Surgical Wisdom Tooth Impaction Extraction',
              price: '\$140.00',
              code: 'DEN-305',
              turnaroundTime: '1 Hour',
              sampleType: 'Oral Surgery',
              description: 'Minor surgical extraction of horizontally impacted third molars.',
            ),
          ],
        ),
        ServiceItemDetail(
          id: 'srv_4',
          title: 'Endocrinology & Metabolic Care',
          description: 'Specialized diabetes management, thyroid disorders, hormonal assays, adrenal evaluation, and metabolic profiling.',
          imagePath: cardiologyImageUrl,
          category: 'Endocrinology',
          startingPrice: '\$40.00',
          subServices: [
            SubServiceItem(
              id: 'sub_4_1',
              name: 'Comprehensive Diabetic Evaluation Panel',
              price: '\$65.00',
              code: 'END-401',
              turnaroundTime: '6 Hours',
              sampleType: 'Fasting Plasma & Serum',
              description: 'Fasting glucose, HbA1c, microalbuminuria, lipid profile, and serum insulin.',
            ),
            SubServiceItem(
              id: 'sub_4_2',
              name: 'Thyroid Ultrasonography & Fine Needle Biopsy',
              price: '\$130.00',
              code: 'END-402',
              turnaroundTime: '24 Hours',
              sampleType: 'Neck Ultrasound & FNA',
              description: 'High-frequency probe localization and cytopathology of solitary thyroid nodules.',
            ),
            SubServiceItem(
              id: 'sub_4_3',
              name: 'Bone Mineral Density (DEXA Dual Scan)',
              price: '\$90.00',
              code: 'END-403',
              turnaroundTime: 'Same Day',
              sampleType: 'Radiological Bone Scan',
              description: 'Osteoporosis risk assessment and T-score quantification of spine and hip.',
            ),
          ],
        ),
        ServiceItemDetail(
          id: 'srv_5',
          title: 'Neurology & Stroke Diagnostics',
          description: 'Comprehensive neurological assessments, digital EEG, nerve conduction studies, and acute stroke intervention.',
          imagePath: angioplastyImageUrl,
          category: 'Neurology',
          startingPrice: '\$80.00',
          subServices: [
            SubServiceItem(
              id: 'sub_5_1',
              name: 'Digital Video Electroencephalogram (EEG)',
              price: '\$140.00',
              code: 'NEU-501',
              turnaroundTime: '24 Hours',
              sampleType: 'Scalp Electrodes',
              description: 'Records cerebral electrical activity to diagnose seizures and encephalopathy.',
            ),
            SubServiceItem(
              id: 'sub_5_2',
              name: 'Electromyography & Nerve Conduction Study (EMG/NCS)',
              price: '\$160.00',
              code: 'NEU-502',
              turnaroundTime: '24 Hours',
              sampleType: 'Motor/Sensory Stimulus',
              description: 'Localizes peripheral neuropathy, carpal tunnel, and motor neuron disease.',
            ),
            SubServiceItem(
              id: 'sub_5_3',
              name: 'Carotid & Vertebral Doppler Duplex Scan',
              price: '\$95.00',
              code: 'NEU-503',
              turnaroundTime: 'Same Day',
              sampleType: 'Ultrasound Duplex',
              description: 'Measures blood flow velocities and stenosis in extracranial cerebral vessels.',
            ),
          ],
        ),
        ServiceItemDetail(
          id: 'srv_6',
          title: 'Orthopaedics & Joint Surgery',
          description: 'Treatment of bone fractures, arthroscopic joint reconstruction, cartilage repair, and total knee/hip arthroplasty.',
          imagePath: dentalImageUrl,
          category: 'Orthopaedics',
          startingPrice: '\$70.00',
          subServices: [
            SubServiceItem(
              id: 'sub_6_1',
              name: 'Knee Diagnostic Arthroscopy & Meniscal Repair',
              price: '\$950.00',
              code: 'ORT-601',
              turnaroundTime: 'Day Surgery',
              sampleType: 'Minimally Invasive Arthroscopy',
              description: 'Fiber-optic camera visualization and suture repair of torn meniscus cartilage.',
            ),
            SubServiceItem(
              id: 'sub_6_2',
              name: 'Intra-Articular Hyaluronic Acid / PRP Joint Injection',
              price: '\$180.00',
              code: 'ORT-602',
              turnaroundTime: '30 Minutes',
              sampleType: 'Sterile Injection',
              description: 'Viscosupplementation and regenerative platelet-rich plasma therapy for osteoarthritis.',
            ),
            SubServiceItem(
              id: 'sub_6_3',
              name: 'High-Resolution Musculoskeletal Ultrasound',
              price: '\$85.00',
              code: 'ORT-603',
              turnaroundTime: 'Same Day',
              sampleType: 'Dynamic Ultrasound',
              description: 'Live dynamic evaluation of rotator cuff tears, tendonitis, and joint effusions.',
            ),
          ],
        ),
        ServiceItemDetail(
          id: 'srv_7',
          title: 'Ophthalmology & Vision Care',
          description: 'State-of-the-art eye care, digital retinal imaging, phacoemulsification cataract surgery, and laser vision correction.',
          imagePath: cardiologyImageUrl,
          category: 'Ophthalmology',
          startingPrice: '\$40.00',
          subServices: [
            SubServiceItem(
              id: 'sub_7_1',
              name: 'Optical Coherence Tomography (OCT Retina & Macula)',
              price: '\$95.00',
              code: 'OPH-701',
              turnaroundTime: 'Same Day',
              sampleType: 'Optical Tomography',
              description: 'Micron-resolution cross-sectional scans of macula for edema and degeneration.',
            ),
            SubServiceItem(
              id: 'sub_7_2',
              name: 'Micro-Incision Phacoemulsification Cataract Surgery',
              price: '\$850.00',
              code: 'OPH-702',
              turnaroundTime: 'Day Surgery',
              sampleType: 'Foldable Hydrophobic IOL',
              description: 'Sutureless ultrasonic emulsification with premium intraocular lens implantation.',
            ),
            SubServiceItem(
              id: 'sub_7_3',
              name: 'Automated Humphrey Visual Field Perimetry',
              price: '\$65.00',
              code: 'OPH-703',
              turnaroundTime: '1 Hour',
              sampleType: 'Computerized Perimetry',
              description: 'Standardized assessment of optic nerve damage in glaucoma management.',
            ),
          ],
        ),
        ServiceItemDetail(
          id: 'srv_8',
          title: 'Radiology & Advanced Imaging',
          description: 'High-field 3T Magnetic Resonance Imaging (MRI), multi-slice computed tomography (CT), and digital radiography.',
          imagePath: angioplastyImageUrl,
          category: 'Radiology',
          startingPrice: '\$60.00',
          subServices: [
            SubServiceItem(
              id: 'sub_8_1',
              name: 'Whole Body Multi-Slice Contrast CT Scan',
              price: '\$320.00',
              code: 'RAD-801',
              turnaroundTime: '12 - 24 Hours',
              sampleType: '128-Slice CT',
              description: 'Volumetric sub-millimeter axial scanning with IV non-ionic contrast enhancement.',
            ),
            SubServiceItem(
              id: 'sub_8_2',
              name: 'High-Field 3.0 Tesla Brain & Spine MRI',
              price: '\$390.00',
              code: 'RAD-802',
              turnaroundTime: '24 Hours',
              sampleType: '3T Magnetic Resonance',
              description: 'Superb soft tissue contrast resolution for neurovascular and musculoskeletal pathologies.',
            ),
            SubServiceItem(
              id: 'sub_8_3',
              name: 'High-Resolution 4D Doppler Abdominal Sonography',
              price: '\$75.00',
              code: 'RAD-803',
              turnaroundTime: 'Same Day',
              sampleType: 'Abdominal Ultrasound',
              description: 'Comprehensive screening of liver, gallbladder, pancreas, kidneys, and spleen.',
            ),
          ],
        ),
      ];
}
