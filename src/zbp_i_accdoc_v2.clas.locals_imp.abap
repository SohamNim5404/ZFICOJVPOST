CLASS lhc_zi_accdoc_v2 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_accdoc_v2 RESULT result.

    METHODS post FOR DETERMINE ON SAVE
      IMPORTING keys FOR zi_accdoc_v2~post.

ENDCLASS.

CLASS lhc_zi_accdoc_v2 IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD post.
  READ ENTITIES OF zi_accdoc_v2 IN LOCAL MODE
           ENTITY zi_accdoc_v2
            ALL FIELDS WITH CORRESPONDING #( keys )
           RESULT DATA(data_read)
           FAILED DATA(failed).

SELECT * FROM zfit_accdoc
    INTO TABLE @DATA(lt_zfit_accdoc).
    DATA:it_final TYPE STANDARD TABLE OF zfit_accdoc,
         wa_final TYPE   zfit_accdoc.

    LOOP AT  lt_zfit_accdoc INTO DATA(wa_doc).
      .wa_final-docid = wa_doc-docid.
      COLLECT wa_final INTO it_final.
      CLEAR:wa_final,wa_doc.
    ENDLOOP.


DATA: lt_doc_h        TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
          lv_cid          TYPE abp_behv_cid,
          ls_doc_h        LIKE LINE OF lt_doc_h,
          ls_glitem       LIKE LINE OF ls_doc_h-%param-_glitems,
          ls_glcurrency   LIKE LINE OF ls_glitem-_currencyamount,
          ls_aritem       LIKE LINE OF ls_doc_h-%param-_aritems, "customer
          ls_taxitems     LIKE LINE OF ls_doc_h-%param-_taxitems,
          ls_custcurrency LIKE LINE OF ls_aritem-_currencyamount,
          ls_apitem       LIKE LINE OF ls_doc_h-%param-_apitems, "vendor
          ls_vencurrency  LIKE LINE OF ls_apitem-_currencyamount,
          lv_docid(10)    TYPE c,
          lv_buzei        TYPE i.

    TYPES : BEGIN OF ty_msg,
              docid(10) TYPE c,
              belnr     TYPE belnr_d,
              msgty(1)  TYPE c,
              msg(200)  TYPE c,
            END OF ty_msg.
    DATA : it_msg    TYPE STANDARD TABLE OF ty_msg,
           wa_msg    TYPE ty_msg,
           lv_result TYPE string,
           lv_msg    TYPE c LENGTH 200.
    DATA : r_date TYPE RANGE OF datum,
           s_date LIKE LINE OF r_date,
           n      TYPE i.

    SELECT * FROM zfit_accdoc
WHERE budat IN @r_date
AND belnr IS INITIAL
INTO TABLE @DATA(it_doc).

    LOOP AT it_final ASSIGNING FIELD-SYMBOL(<fs_doc>).
       clear:ls_doc_h,lt_doc_h.
       CLEAR: ls_aritem, ls_apitem, ls_glitem, ls_glcurrency, ls_custcurrency, ls_vencurrency.
*      IF lv_docid <> <fs_doc>-docid.
        lv_docid = <fs_doc>-docid.

        LOOP AT it_doc ASSIGNING FIELD-SYMBOL(<fs_member>) WHERE docid = <fs_doc>-docid.

*          lv_cid = <fs_member>-id.

          IF <fs_member>-hkont IS NOT INITIAL.
            lv_buzei = lv_buzei + 1.
            ls_glitem-glaccountlineitem = lv_buzei.         ls_glitem-%control-glaccountlineitem = if_abap_behv=>mk-on.
            ls_glitem-glaccount         = <fs_member>-hkont.ls_glitem-%control-glaccount = if_abap_behv=>mk-on.
            ls_glitem-costcenter        = <fs_member>-kostl.ls_glitem-%control-costcenter = if_abap_behv=>mk-on.
            ls_glitem-profitcenter      = <fs_member>-prctr.ls_glitem-%control-profitcenter = if_abap_behv=>mk-on.
            ls_glitem-housebank = <fs_member>-bank.       ls_glitem-%control-housebank = if_abap_behv=>mk-on.
            ls_glitem-housebankaccount = <fs_member>-hbkid.   ls_glitem-%control-housebankaccount = if_abap_behv=>mk-on.
            ls_glitem-businessplace = <fs_member>-bupla.ls_glitem-%control-businessplace = if_abap_behv=>mk-on.
            ls_glitem-assignmentreference = <fs_member>-zuonr.ls_glitem-%control-assignmentreference = if_abap_behv=>mk-on.
            ls_glitem-documentitemtext = <fs_member>-sgtxt.ls_glitem-%control-documentitemtext = if_abap_behv=>mk-on.
            ls_glitem-taxcode = <fs_member>-mwskz.ls_glitem-%control-taxcode = if_abap_behv=>mk-on.
*            ls_glitem-taxcountry = <fs_member>-taxcountry.ls_glitem-%control-taxcountry = if_abap_behv=>mk-on.
            ls_glitem-taxjurisdiction = ''.     ls_glitem-%control-taxjurisdiction = if_abap_behv=>mk-on.

            IF <fs_member>-shkzg = 'CR'. "CR = H
              ls_glcurrency-journalentryitemamount = <fs_member>-dmbtr * -1.
            ELSE.
              ls_glcurrency-journalentryitemamount = <fs_member>-dmbtr.
            ENDIF.
            ls_glcurrency-%control-journalentryitemamount = if_abap_behv=>mk-on.
            ls_glcurrency-currency = <fs_member>-waers.             ls_glcurrency-%control-currency = if_abap_behv=>mk-on.
            ls_glcurrency-currencyrole = '00'.                      ls_glcurrency-%control-currencyrole = if_abap_behv=>mk-on.


            ls_glitem-%control-_currencyamount = if_abap_behv=>mk-on.
            ls_doc_h-%param-%control-_glitems = if_abap_behv=>mk-on.

            APPEND ls_glcurrency TO ls_glitem-_currencyamount.
            APPEND ls_glitem TO ls_doc_h-%param-_glitems.
          ENDIF.


          IF <fs_member>-kunnr IS NOT INITIAL.
            lv_buzei = lv_buzei + 1.
            ls_aritem-glaccountlineitem = lv_buzei. ls_aritem-%control-glaccountlineitem = if_abap_behv=>mk-on.
            ls_aritem-customer = <fs_member>-kunnr. ls_aritem-%control-customer = if_abap_behv=>mk-on.
            ls_aritem-specialglcode     = <fs_member>-umskz.ls_aritem-%control-specialglcode = if_abap_behv=>mk-on.
            ls_aritem-businessplace = <fs_member>-bupla.ls_aritem-%control-businessplace = if_abap_behv=>mk-on.
            ls_aritem-assignmentreference = <fs_member>-zuonr.ls_aritem-%control-assignmentreference = if_abap_behv=>mk-on.
            ls_aritem-documentitemtext = <fs_member>-sgtxt.ls_aritem-%control-documentitemtext = if_abap_behv=>mk-on.
            ls_aritem-taxcode          = <fs_member>-mwskz. ls_aritem-%control-taxcode  = if_abap_behv=>mk-on.
*            ls_aritem-taxcountry       = <fs_member>-taxcountry.ls_aritem-%control-taxcountry = if_abap_behv=>mk-on.
            ls_aritem-taxjurisdiction = ''.ls_aritem-%control-taxjurisdiction = if_abap_behv=>mk-on.

            IF <fs_member>-shkzg = 'CR'. "CR = H
              ls_custcurrency-journalentryitemamount = <fs_member>-dmbtr * -1.
            ELSE.
              ls_custcurrency-journalentryitemamount = <fs_member>-dmbtr.
            ENDIF.

            ls_custcurrency-%control-journalentryitemamount = if_abap_behv=>mk-on.
            ls_custcurrency-currency = <fs_member>-waers.ls_custcurrency-%control-currency = if_abap_behv=>mk-on.
            ls_custcurrency-currencyrole = '00'.         ls_custcurrency-%control-currencyrole = if_abap_behv=>mk-on.

            ls_aritem-%control-_currencyamount = if_abap_behv=>mk-on.
            ls_doc_h-%param-%control-_aritems = if_abap_behv=>mk-on.

            APPEND ls_custcurrency TO ls_aritem-_currencyamount.
            APPEND ls_aritem TO ls_doc_h-%param-_aritems.
          ENDIF.


          IF <fs_member>-lifnr IS NOT INITIAL.
            lv_buzei = lv_buzei + 1.
            ls_apitem-glaccountlineitem = lv_buzei. ls_apitem-%control-glaccountlineitem = if_abap_behv=>mk-on.
            ls_apitem-supplier = <fs_member>-lifnr. ls_apitem-%control-supplier = if_abap_behv=>mk-on.
            ls_apitem-specialglcode = <fs_member>-umskz. ls_apitem-%control-specialglcode = if_abap_behv=>mk-on.
            ls_apitem-businessplace = <fs_member>-bupla.ls_apitem-%control-businessplace = if_abap_behv=>mk-on.
            ls_apitem-assignmentreference = <fs_member>-zuonr.ls_apitem-%control-assignmentreference = if_abap_behv=>mk-on.
            ls_apitem-documentitemtext = <fs_member>-sgtxt.ls_apitem-%control-documentitemtext = if_abap_behv=>mk-on.
            ls_apitem-paymentmethod = <fs_member>-zlsch.ls_apitem-%control-paymentmethod = if_abap_behv=>mk-on.
            ls_apitem-taxcode =  <fs_member>-mwskz. ls_apitem-%control-taxcode = if_abap_behv=>mk-on.
*            ls_apitem-taxcountry = <fs_member>-taxcountry.ls_apitem-%control-taxcountry = if_abap_behv=>mk-on.
            ls_apitem-taxjurisdiction = ''.ls_apitem-%control-taxjurisdiction = if_abap_behv=>mk-on.


            IF <fs_member>-shkzg = 'CR'. "CR = H
              ls_vencurrency-journalentryitemamount = <fs_member>-dmbtr * -1.
            ELSE.
              ls_vencurrency-journalentryitemamount = <fs_member>-dmbtr.
            ENDIF.
            ls_vencurrency-%control-journalentryitemamount = if_abap_behv=>mk-on.
            ls_vencurrency-currency = <fs_member>-waers.  ls_vencurrency-%control-currency = if_abap_behv=>mk-on.


            ls_apitem-%control-_currencyamount = if_abap_behv=>mk-on.
            ls_doc_h-%param-%control-_apitems = if_abap_behv=>mk-on.

            APPEND ls_vencurrency TO ls_apitem-_currencyamount.
            APPEND ls_apitem TO ls_doc_h-%param-_apitems.

          ENDIF.

          CLEAR: ls_aritem, ls_apitem, ls_glitem, ls_glcurrency, ls_custcurrency, ls_vencurrency.
        ENDLOOP.


        ls_doc_h-%cid = <fs_doc>-docid.
        ls_doc_h-%param-companycode = <fs_member>-bukrs.
        ls_doc_h-%param-documentreferenceid = <fs_member>-xblnr.
        ls_doc_h-%param-createdbyuser = sy-uname.
        ls_doc_h-%param-businesstransactiontype = 'RFPI'.
        ls_doc_h-%param-accountingdocumenttype = <fs_member>-blart.
        data:documentdate type budat,
             postingdate  TYPE budat.
        CONCATENATE:<fs_member>-bldat+6(4) <fs_member>-bldat+3(2) <fs_member>-bldat+0(2) INTO   documentdate,
                    <fs_member>-budat+6(4) <fs_member>-budat+3(2) <fs_member>-budat+0(2) INTO   postingdate.

        ls_doc_h-%param-documentdate = documentdate.
        ls_doc_h-%param-postingdate = postingdate.
        ls_doc_h-%param-accountingdocumentheadertext = <fs_member>-bktxt.
        ls_doc_h-%param-taxdeterminationdate = documentdate.
        ls_doc_h-%param-taxreportingdate     = documentdate.
*            ls_doc_h-%param-


        ls_doc_h-%param-%control-companycode = if_abap_behv=>mk-on.
        ls_doc_h-%param-%control-documentreferenceid = if_abap_behv=>mk-on.
        ls_doc_h-%param-%control-createdbyuser = if_abap_behv=>mk-on.
        ls_doc_h-%param-%control-businesstransactiontype = if_abap_behv=>mk-on.
        ls_doc_h-%param-%control-accountingdocumenttype = if_abap_behv=>mk-on.
        ls_doc_h-%param-%control-documentdate = if_abap_behv=>mk-on.
        ls_doc_h-%param-%control-postingdate = if_abap_behv=>mk-on.
        ls_doc_h-%param-%control-accountingdocumentheadertext = if_abap_behv=>mk-on.
*            ls_doc_h-%param-%control-documentreferenceid = if_abap_behv=>mk-on.
        ls_doc_h-%param-%control-taxdeterminationdate = if_abap_behv=>mk-on.
        ls_doc_h-%param-%control-taxreportingdate = if_abap_behv=>mk-on.

        APPEND ls_doc_h TO lt_doc_h.

        IF lt_doc_h IS NOT INITIAL.

          MODIFY ENTITIES OF i_journalentrytp
              ENTITY journalentry
              EXECUTE post FROM lt_doc_h
              FAILED FINAL(ls_failed_deep)
              REPORTED FINAL(ls_reported_deep)
              MAPPED FINAL(ls_mapped_deep).


          IF ls_failed_deep IS NOT INITIAL.
            LOOP AT ls_reported_deep-journalentry ASSIGNING FIELD-SYMBOL(<ls_report>).
              APPEND VALUE #( %create = if_abap_behv=>mk-on
                          %msg = <ls_report>-%msg ) TO reported-zi_accdoc_v2.
            ENDLOOP.

          ELSE.
*                COMMIT ENTITIES BEGIN
*                RESPONSE OF i_journalentrytp
*                FAILED DATA(lt_commit_failed)
*                REPORTED DATA(lt_commit_reported).
*
*
*                IF lt_commit_reported IS NOT INITIAL.
*                  LOOP AT lt_commit_reported-journalentry ASSIGNING FIELD-SYMBOL(<ls_invoice>).
*                    IF <ls_invoice>-accountingdocument IS NOT INITIAL.
*                      "Success case
*                      CLEAR : wa_msg.
*                      wa_msg-belnr    = <ls_invoice>-accountingdocument.
*                      wa_msg-msgty    = 'S'.
*                      CONCATENATE  'Journal Posted Doc No. ' <ls_invoice>-accountingdocument INTO wa_msg-msg SEPARATED BY ''.
*                      APPEND wa_msg TO it_msg.
*                      CLEAR wa_msg.
*
*                      UPDATE zfit_accdoc SET belnr = @<ls_invoice>-accountingdocument,
*                                              gjahr = @<ls_invoice>-fiscalyear,
*                                              bukrs = @<ls_invoice>-companycode
*                                        WHERE docid = @<fs_member>-docid.
*                      COMMIT WORK.
*                    ELSE.
*
*                      "Error handling
*
*                      CLEAR : wa_msg.
*                      wa_msg-docid    = <fs_member>-docid.
*                      wa_msg-msgty    = 'E'.
*                      CONCATENATE 'Error hile Journal Entry' <fs_member>-docid
*                      INTO wa_msg-msg SEPARATED BY ''.
*                      APPEND wa_msg TO it_msg.
*                      CLEAR wa_msg.
*                    ENDIF.
*
*
*


          ENDIF.
       zbp_i_accdoc_v2=>mapped_journalentrytp-journalentry =  ls_mapped_deep-journalentry.

        ENDIF.
*      ENDIF.
    ENDLOOP.



  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_accdoc_v2 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_accdoc_v2 IMPLEMENTATION.

  METHOD save_modified.
  LOOP AT zbp_i_accdoc_v2=>mapped_journalentrytp-journalentry ASSIGNING FIELD-SYMBOL(<fs_pr_mapped>).
      CONVERT KEY OF i_journalentrytp FROM <fs_pr_mapped>-%pid TO DATA(ls_pr_key).
      <fs_pr_mapped>-accountingdocument = ls_pr_key-accountingdocument.
  ENDLOOP.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
