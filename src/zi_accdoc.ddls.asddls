@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view ZFIT_ACCDOC'
define view entity ZI_ACCDOC
  as select from zfit_accdoc
  association to parent ZINS_I_JV_HEAD as _XLUser on  $projection.EndUser = _XLUser.EndUser
                                                  and $projection.FileId  = _XLUser.FileId
{
  key id    as Id,
  key end_user as EndUser,
  key file_id  as FileId,
  key line_id  as LineId,
  key line_no  as LineNumber,
      belnr as Belnr,
      docid as Docid,
      bukrs as Bukrs,
      gjahr as Gjahr,
      blart as Blart,
      bldat as Bldat,
      budat as Budat,
      waers as Waers,
      bupla as Bupla,
      secco as Secco,
      xblnr as Xblnr,
      bktxt as Bktxt,
      hkont as Hkont,
      dmbtr as Dmbtr,
      //      wrbtr as Wrbtr,
      shkzg as Shkzg,
      kostl as Kostl,
      prctr as Prctr,
      mwskz as Mwskz,
      bank  as Bank,
      hbkid as Hbkid,
      kunnr as Kunnr,
      lifnr as Lifnr,
      umskz as Umskz,
      sgtxt as sgtxt,
      zuonr as ZUONR,
      zlsch as zlsch,
      uname as uname,
      lastchangedat,
      _XLUser
      
      
}
