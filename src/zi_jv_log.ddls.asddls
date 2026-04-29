@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface for JV Log'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_JV_LOG as select from ztfi_jv_log
{
    key zid as Zid,
    docid as Docid,
    lifnr as Lifnr,
    kostl as Kostl,
    belnr as Belnr,
    bukrs as Bukrs,
    gjahr as Gjahr,
    mess as Mess
}
