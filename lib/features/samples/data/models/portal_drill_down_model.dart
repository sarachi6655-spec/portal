class PortalDrillDownResponse {
  final String status;
  final String message;
  final List<PortalDrillDownItemModel> data;

  PortalDrillDownResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory PortalDrillDownResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'];
    final List<PortalDrillDownItemModel> items = [];
    if (rawList is List) {
      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          items.add(PortalDrillDownItemModel.fromJson(item));
        }
      }
    }

    return PortalDrillDownResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: items,
    );
  }
}

class PortalDrillDownItemModel {
  final String referenceId;
  final String orderReference;
  final String orderCategory;
  final String contactPerson;
  final String poNo;
  final String orderBookingMonth;
  final String poDate;
  final String salesPerson;
  final String bookingDate;
  final String companyCurrency;
  final String projectName;
  final String location;
  final String site;
  final String orderStatus;
  final String startDate;
  final String endDate;
  final String orderCurrency;
  final String totalCost;
  final String taxGroup;
  final String taxValue;
  final String taxExempt;
  final String specialDiscount;
  final String marginAmount;
  final String marginPercentage;
  final String orderValue;
  final String grandTotal;
  final String approvedDate;
  final String approvedBy;
  final String rejectedDate;
  final String rejectedBy;
  final String acknowledgeBy;
  final String acknowledgementDate;
  final Map<String, dynamic> rawJson;

  PortalDrillDownItemModel({
    required this.referenceId,
    required this.orderReference,
    required this.orderCategory,
    required this.contactPerson,
    required this.poNo,
    required this.orderBookingMonth,
    required this.poDate,
    required this.salesPerson,
    required this.bookingDate,
    required this.companyCurrency,
    required this.projectName,
    required this.location,
    required this.site,
    required this.orderStatus,
    required this.startDate,
    required this.endDate,
    required this.orderCurrency,
    required this.totalCost,
    required this.taxGroup,
    required this.taxValue,
    required this.taxExempt,
    required this.specialDiscount,
    required this.marginAmount,
    required this.marginPercentage,
    required this.orderValue,
    required this.grandTotal,
    required this.approvedDate,
    required this.approvedBy,
    required this.rejectedDate,
    required this.rejectedBy,
    required this.acknowledgeBy,
    required this.acknowledgementDate,
    required this.rawJson,
  });

  factory PortalDrillDownItemModel.fromJson(Map<String, dynamic> json) {
    String str(String key) => json[key]?.toString().trim() ?? '';

    return PortalDrillDownItemModel(
      referenceId: str('ReferenceID'),
      orderReference: str('OrderReference'),
      orderCategory: str('OrderCategory'),
      contactPerson: str('ContactPerson'),
      poNo: str('PONo'),
      orderBookingMonth: str('OrderBookingMonth'),
      poDate: str('PODate'),
      salesPerson: str('SalesPerson'),
      bookingDate: str('BookingDate'),
      companyCurrency: str('CompanyCurrency'),
      projectName: str('ProjectName'),
      location: str('Location'),
      site: str('Site'),
      orderStatus: str('OrderStatus'),
      startDate: str('StartDate'),
      endDate: str('EndDate'),
      orderCurrency: str('OrderCurrency'),
      totalCost: str('TotalCost'),
      taxGroup: str('TaxGroup'),
      taxValue: str('TaxValue'),
      taxExempt: str('TaxExempt'),
      specialDiscount: str('SpecialDiscount'),
      marginAmount: str('MarginAmount'),
      marginPercentage: str('MarginPercentage'),
      orderValue: str('OrderValue'),
      grandTotal: str('GrandTotal'),
      approvedDate: str('ApprovedDate'),
      approvedBy: str('ApprovedBy'),
      rejectedDate: str('RejectedDate'),
      rejectedBy: str('RejectedBy'),
      acknowledgeBy: str('AcknowledgeBy'),
      acknowledgementDate: str('AcknowledgementDate'),
      rawJson: json,
    );
  }

  String getValue(String key) => rawJson[key]?.toString().trim() ?? '';

  String get displayTitle {
    if (orderReference.isNotEmpty) return orderReference;
    final enqRef = rawJson['EnquiryReference']?.toString();
    if (enqRef != null && enqRef.isNotEmpty) return enqRef;
    if (referenceId.isNotEmpty) return '#$referenceId';
    final enqNo = rawJson['EnquiryNo']?.toString();
    if (enqNo != null && enqNo.isNotEmpty) return enqNo;
    return 'Details';
  }

  bool matchesSearch(String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();

    for (final val in rawJson.values) {
      if (val != null && val.toString().toLowerCase().contains(q)) {
        return true;
      }
    }
    return false;
  }

  String get effectiveCurrency =>
      companyCurrency.isNotEmpty ? companyCurrency : (orderCurrency.isNotEmpty ? orderCurrency : 'INR');

  String get formattedGrandTotal {
    if (grandTotal.isEmpty) return '-';
    final numVal = double.tryParse(grandTotal);
    if (numVal != null) {
      return '$effectiveCurrency ${numVal.toStringAsFixed(2)}';
    }
    return '$effectiveCurrency $grandTotal';
  }

  String get formattedTotalCost {
    if (totalCost.isEmpty) return '-';
    final numVal = double.tryParse(totalCost);
    if (numVal != null) {
      return '$effectiveCurrency ${numVal.toStringAsFixed(2)}';
    }
    return '$effectiveCurrency $totalCost';
  }

  String get formattedOrderValue {
    if (orderValue.isEmpty) return '-';
    final numVal = double.tryParse(orderValue);
    if (numVal != null) {
      return '$effectiveCurrency ${numVal.toStringAsFixed(2)}';
    }
    return '$effectiveCurrency $orderValue';
  }
}
