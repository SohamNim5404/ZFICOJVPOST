//@AccessControl.authorizationCheck: #NOT_REQUIRED
//@EndUserText.label: 'consumption view for JV Log'
//@Metadata.ignorePropagatedAnnotations: true
//define view entity ZC_JV_LOG as projection on ZI_JV_LOG
//{
//    key Zid,
//    Docid,
//    Lifnr,
//    Kostl,
//    Belnr,
//    Bukrs,
//    Gjahr,
//    Mess
//}
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption view for JV Log'
@Metadata.allowExtensions: true

@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

/* --- Header & Sorting Configuration --- */
@UI.headerInfo: {
    typeName: 'JV Log',
    typeNamePlural: 'JV Logs',
    title: { type: #STANDARD, value: 'Zid' },
    description: { type: #STANDARD, value: 'Mess' }
}

@UI.presentationVariant: [{
    sortOrder: [{ by: 'Zid', direction: #DESC }]
}]

define root  view entity ZC_JV_LOG
  provider contract transactional_query
  as projection on ZI_JV_LOG
{
    /* --- Facet for Object Page --- */
    @UI.facet: [{
        id: 'General',
        purpose: #STANDARD,
        type: #IDENTIFICATION_REFERENCE,
        label: 'JV Log Details',
        position: 10
    }]

    /* --- Field Annotations --- */

    @UI.lineItem:       [{ position: 10, label: 'JV ID' }]
    @UI.selectionField: [{ position: 10 }]
    @UI.identification: [{ position: 10, label: 'JV ID' }]
  key Zid,

    @UI.lineItem:       [{ position: 20, label: 'Document ID' }]
    @UI.selectionField: [{ position: 20 }]
    @UI.identification: [{ position: 20, label: 'Document ID' }]
    Docid,

    @UI.lineItem:       [{ position: 30, label: 'Vendor' }]
    @UI.selectionField: [{ position: 30 }]
    @UI.identification: [{ position: 30, label: 'Vendor' }]
    Lifnr,

    @UI.lineItem:       [{ position: 40, label: 'Cost Center' }]
    @UI.selectionField: [{ position: 40 }]
    @UI.identification: [{ position: 40, label: 'Cost Center' }]
    Kostl,

    @UI.lineItem:       [{ position: 50, label: 'Accounting Doc' }]
    @UI.identification: [{ position: 50, label: 'Accounting Doc' }]
    Belnr,

    @UI.lineItem:       [{ position: 60, label: 'Company Code' }]
    @UI.identification: [{ position: 60, label: 'Company Code' }]
    Bukrs,

    @UI.lineItem:       [{ position: 70, label: 'Fiscal Year' }]
    @UI.identification: [{ position: 70, label: 'Fiscal Year' }]
    Gjahr,

    @UI.lineItem:       [{ position: 80, label: 'Message' }]
    @UI.identification: [{ position: 80, label: 'Message' }]
    Mess
}
