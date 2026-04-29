@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'JV REPORT'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_ACCDOC_V2
  as select from zfit_accdoc
{
        key id    as Id,
        key docid    as Docid,
        key hkont    as Hkont,
//  key end_user as enduser,
//  key file_id  as fileid,
//  key line_id  as lineid,
//  key line_no  as linenumber,
      belnr    as Belnr,
     
      bukrs    as Bukrs,
      gjahr    as Gjahr,
      blart    as Blart,
      bldat    as Bldat,
      budat    as Budat,
      waers    as Waers,
      bupla    as Bupla,
      secco    as Secco,
      xblnr    as Xblnr,
      bktxt    as Bktxt,
      
      @Semantics.amount.currencyCode : 'waers'
      dmbtr    as Dmbtr,
      //      wrbtr as Wrbtr,
      shkzg    as Shkzg,
      kostl    as Kostl,
      prctr    as Prctr,
      mwskz    as Mwskz,
      bank     as Bank,
      hbkid    as Hbkid,
      kunnr    as Kunnr,
      lifnr    as Lifnr,
      umskz    as Umskz,
      sgtxt    as sgtxt,
      zuonr    as ZUONR,
      zlsch    as zlsch,
      uname    as uname
}
