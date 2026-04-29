CLASS lhc_xlhead DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR xlhead RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR xlhead RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE xlhead.

    METHODS uploadexceldata FOR MODIFY
      IMPORTING keys FOR ACTION xlhead~uploadexceldata RESULT result.

    METHODS fillfilestatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR xlhead~fillfilestatus.

    METHODS fillselectedstatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR xlhead~fillselectedstatus.

ENDCLASS.

CLASS lhc_xlhead IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_entities>).

      APPEND CORRESPONDING #( <lfs_entities> ) TO mapped-xlhead
        ASSIGNING FIELD-SYMBOL(<lfs_xlhead>).

      <lfs_xlhead>-enduser = lv_user.

      IF <lfs_xlhead>-fileid IS INITIAL.
        TRY.
            <lfs_xlhead>-fileid = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error.
            " Do nothing – proceed to next entry
        ENDTRY.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD uploadexceldata.

    DATA:
      lt_rows         TYPE STANDARD TABLE OF string,
      lv_content      TYPE string,
      lo_table_descr  TYPE REF TO cl_abap_tabledescr,
      lo_struct_descr TYPE REF TO cl_abap_structdescr,
      lt_excel        TYPE STANDARD TABLE OF zfit_accdoc, "zmaks_cl_bp_xl_user=>gty_gr_xl,
      wa_excel        TYPE zfit_accdoc,
      lt_excel1       TYPE STANDARD TABLE OF zbp_ins_i_jv_head=>gty_gr_xl1,
      lt_data         TYPE TABLE FOR CREATE ZINS_I_JV_HEAD\_xldata,
      lv_index        TYPE sy-index,
      lv_posnr        TYPE i_billingdocumentitem-billingdocumentitem.

    DATA:
      lv_matnr(18) TYPE c,
      lv_lifnr(10) TYPE c,
      pymt_trm     TYPE i_purchaseordertp_2-paymentterms.

    DATA: lt_poparallel TYPE cl_abap_parallel=>t_in_inst_tab .

*******************************************BOI DD END******************************************************
    DATA(n2) = 0.

    FIELD-SYMBOLS:
      <lfs_col_header> TYPE string.

    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).

    READ ENTITIES OF zins_i_jv_head IN LOCAL MODE
      ENTITY xlhead
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_file_entity).

    DATA(lv_attachment) = lt_file_entity[ 1 ]-attachment.
    CHECK lv_attachment IS NOT INITIAL.

    " Move Excel Data to Internal Table
    DATA(lo_xlsx) = xco_cp_xlsx=>document->for_file_content(
                      iv_file_content = lv_attachment
                    )->read_access( ).

    DATA(lo_worksheet) = lo_xlsx->get_workbook( )->worksheet->at_position( 1 ).

    DATA(lo_selection_pattern) =
      xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).

    DATA(lo_execute) = lo_worksheet->select(
                         lo_selection_pattern
                       )->row_stream( )->operation->write_to(
*                         REF #( lt_excel )
                          REF #( lt_excel1 )
                       ).

    lo_execute->set_value_transformation(
      xco_cp_xlsx_read_access=>value_transformation->string_value
    )->if_xco_xlsx_ra_operation~execute( ).

    " Get number of columns in upload file for validation
    TRY.
        lo_table_descr ?= cl_abap_tabledescr=>describe_by_data(
*                            p_data = lt_excel
                             p_data = lt_excel1
                          ).

        lo_struct_descr ?= lo_table_descr->get_table_line_type( ).

        DATA(lv_no_of_cols) = lines( lo_struct_descr->components ).

      CATCH cx_sy_move_cast_error.
        " Implement error handling
    ENDTRY.

    DELETE lt_excel1 INDEX 1 .
    LOOP AT lt_excel1 ASSIGNING FIELD-SYMBOL(<fs_excel_n1>).

      n2 += 1.
      wa_excel-docid    = <fs_excel_n1>-docid.
      wa_excel-bukrs     = <fs_excel_n1>-bukrs.
      wa_excel-gjahr     = <fs_excel_n1>-gjahr.
      wa_excel-blart        = <fs_excel_n1>-blart.
      wa_excel-bldat        = <fs_excel_n1>-bldat.
      wa_excel-budat          = <fs_excel_n1>-budat.
      wa_excel-waers = <fs_excel_n1>-waers.
      wa_excel-bupla     = <fs_excel_n1>-bupla.
      wa_excel-secco         = <fs_excel_n1>-secco.
      wa_excel-xblnr         = <fs_excel_n1>-xblnr.
      wa_excel-bktxt    = <fs_excel_n1>-bktxt.
      wa_excel-hkont     = <fs_excel_n1>-hkont.
      wa_excel-dmbtr            = <fs_excel_n1>-dmbtr.
      wa_excel-shkzg       = <fs_excel_n1>-shkzg.
      wa_excel-kostl = <fs_excel_n1>-kostl.
      wa_excel-prctr    = <fs_excel_n1>-prctr.
      wa_excel-mwskz  = <fs_excel_n1>-mwskz.
      wa_excel-bank    = <fs_excel_n1>-bank.
      wa_excel-hbkid            = <fs_excel_n1>-hbkid.
      wa_excel-kunnr       = <fs_excel_n1>-kunnr.
      wa_excel-lifnr         = <fs_excel_n1>-lifnr.
      wa_excel-umskz       = <fs_excel_n1>-umskz.
      wa_excel-belnr       = <fs_excel_n1>-belnr.
*      wa_excel-dp_3         = <fs_excel_n1>-dp_3.
      wa_excel-sgtxt         = <fs_excel_n1>-sgtxt.
      wa_excel-zuonr       = <fs_excel_n1>-zuonr.
      wa_excel-zlsch      = <fs_excel_n1>-zlsch.
      wa_excel-uname        = <fs_excel_n1>-uname.
*      wa_excel-file_id  = <fs_excel_n1>-
      APPEND wa_excel TO lt_excel.
      CLEAR : wa_excel, lv_lifnr, pymt_trm, lv_matnr.
    ENDLOOP.

    " Fill Line ID / Line Number
    TRY.
        DATA(lv_line_id) = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
    ENDTRY.

    LOOP AT lt_excel ASSIGNING FIELD-SYMBOL(<lfs_excel>).

      <lfs_excel>-line_id     = lv_line_id.
      <lfs_excel>-line_no     = sy-tabix.
      <lfs_excel>-file_id =   keys[ 1 ]-fileid.
    ENDLOOP.

*    DELETE lt_excel WHERE id = ''.

*    SELECT *
*    from ZINS_EXCEL_DATA
*    FOR ALL ENTRIES IN @lt_excel
*    WHERE inspection = @lt_excel-inspection
*    AND   BATCH = @lt_excel-batch
*    INTO TABLE @DATA(IT_LOG).
*    IF sy-subrc <> 0.
      lt_data = VALUE #(
        (
          %cid_ref  = keys[ 1 ]-%cid_ref
          %is_draft = keys[ 1 ]-%is_draft
          enduser   = keys[ 1 ]-enduser
          fileid    = keys[ 1 ]-fileid
          %target   = VALUE #(
            FOR lwa_excel IN lt_excel
            (
                  "      %cid      = |{ lwa_excel-po_number }_{ lwa_excel-po_item }_{ lwa_excel-site_id }|
              %cid      = keys[ 1 ]-%cid_ref
              %is_draft = keys[ 1 ]-%is_draft
              %data     = VALUE #(
                enduser        = keys[ 1 ]-enduser
                fileid         = keys[ 1 ]-fileid
                lineid         = lwa_excel-line_id
                linenumber     = lwa_excel-line_no
                id    = lwa_excel-id
                docid    = lwa_excel-docid
                bukrs     = lwa_excel-bukrs
                gjahr     = lwa_excel-gjahr
                blart        = lwa_excel-blart
                bldat        = lwa_excel-bldat
      budat          = lwa_excel-budat
      waers = lwa_excel-waers
      bupla     = lwa_excel-bupla
      secco         = lwa_excel-secco
      xblnr         = lwa_excel-xblnr
      bktxt    = lwa_excel-bktxt
      hkont     = lwa_excel-hkont
      dmbtr            = lwa_excel-dmbtr
      shkzg       = lwa_excel-shkzg
      kostl = lwa_excel-kostl
      prctr    = lwa_excel-prctr
      mwskz  = lwa_excel-mwskz
      bank    = lwa_excel-bank
      hbkid            = lwa_excel-hbkid
      kunnr       = lwa_excel-kunnr
      lifnr         = lwa_excel-lifnr
      umskz       = lwa_excel-umskz
      belnr       = lwa_excel-belnr
*      wa_excel-dp_3         = <fs_excel_n1>-dp_3.
      sgtxt         = lwa_excel-sgtxt
      zuonr       = lwa_excel-zuonr
      zlsch      = lwa_excel-zlsch
      uname        = lwa_excel-uname
      )
                     %control = VALUE #(
      enduser        = if_abap_behv=>mk-on
      fileid         = if_abap_behv=>mk-on
      lineid         = if_abap_behv=>mk-on
      linenumber     = if_abap_behv=>mk-on
      id             = if_abap_behv=>mk-on
      docid     = if_abap_behv=>mk-on
      bukrs     = if_abap_behv=>mk-on
      gjahr        = if_abap_behv=>mk-on
      blart        = if_abap_behv=>mk-on
      bldat          = if_abap_behv=>mk-on
      budat       = if_abap_behv=>mk-on
      waers     = if_abap_behv=>mk-on
      bupla         = if_abap_behv=>mk-on
      secco         = if_abap_behv=>mk-on
      xblnr    = if_abap_behv=>mk-on
      bktxt     = if_abap_behv=>mk-on
      hkont            = if_abap_behv=>mk-on
      dmbtr       = if_abap_behv=>mk-on
      shkzg = if_abap_behv=>mk-on
      kostl    = if_abap_behv=>mk-on
      prctr  = if_abap_behv=>mk-on
      mwskz    = if_abap_behv=>mk-on
      bank       = if_abap_behv=>mk-on
      hbkid             = if_abap_behv=>mk-on
      kunnr         = if_abap_behv=>mk-on
      lifnr        = if_abap_behv=>mk-on
      umskz       = if_abap_behv=>mk-on
      belnr         = if_abap_behv=>mk-on
      sgtxt       = if_abap_behv=>mk-on
      zuonr         = if_abap_behv=>mk-on
      zlsch         = if_abap_behv=>mk-on
      uname       = if_abap_behv=>mk-on
    )
      )
    )
  )
).

      " Delete Existing entry for user if any
      READ ENTITIES OF ZINS_I_JV_HEAD IN LOCAL MODE
        ENTITY xlhead BY \_xldata
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_existing_xldata).

      IF lt_existing_xldata IS NOT INITIAL.

        MODIFY ENTITIES OF ZINS_I_JV_HEAD IN LOCAL MODE
          ENTITY xldata
          DELETE FROM VALUE #(
            FOR lwa_data IN lt_existing_xldata
            (
              %key      = lwa_data-%key
              %is_draft = lwa_data-%is_draft
            )
          )
          MAPPED   DATA(lt_del_mapped)
          REPORTED DATA(lt_del_reported)
          FAILED   DATA(lt_del_failed).

      ENDIF.

      "Add New Entry for XLData (association)
      MODIFY ENTITIES OF ZINS_I_JV_HEAD IN LOCAL MODE
        ENTITY xlhead CREATE BY \_xldata
        AUTO FILL CID WITH lt_data.


      "Modify Status
      MODIFY ENTITIES OF ZINS_I_JV_HEAD IN LOCAL MODE
        ENTITY xlhead
        UPDATE FROM VALUE #(
          (
            %tky                 = lt_file_entity[ 1 ]-%tky  "keys[ 1 ]-%tky
            filestatus           = 'File Uploaded'
            %control-filestatus  = if_abap_behv=>mk-on
          )
        )
        MAPPED DATA(lt_upd_mapped)
        FAILED DATA(lt_upd_failed)
        REPORTED DATA(lt_upd_reported).

      "Read Updated Entry
      READ ENTITIES OF ZINS_I_JV_HEAD IN LOCAL MODE
        ENTITY xlhead
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_updated_xlhead).

      "Send Status back to front end
      result = VALUE #(
        FOR lwa_upd_head IN lt_updated_xlhead
        (
          %tky      = lwa_upd_head-%tky
          %is_draft = lwa_upd_head-%is_draft
          %param    = lwa_upd_head
        )
      ).

      DATA(lo_proc) = NEW cl_abap_parallel( p_percentage = 30 )  .

       IF lt_excel IS NOT INITIAL .

      INSERT NEW zcl_jv_parallel(  lt_po_details = CORRESPONDING #( lt_excel )  )
      INTO TABLE lt_poparallel.

      IF lt_poparallel IS NOT INITIAL .

        lo_proc->run_inst(  EXPORTING p_in_tab = lt_poparallel
                                     p_debug = abap_false
                            IMPORTING p_out_tab = DATA(lt_finished)  ).
      ENDIF.
    ENDIF.
    LOOP AT lt_finished INTO DATA(lo_inst).
      DATA lo_res_parallel TYPE REF TO zcl_jv_parallel.
      lo_res_parallel ?= lo_inst-inst.
      IF lo_res_parallel IS BOUND.
        " Loop over collected messages from the parallel execution
        LOOP AT lo_res_parallel->it_msg INTO DATA(ls_msg).
          IF ls_msg-msgty = 'S'.
            " Append Success message to UI
            APPEND VALUE #(
              %tky = keys[ 1 ]-%tky " Link to correct record key to trigger UI popup
              %msg = new_message_with_text(
                       severity = if_abap_behv_message=>severity-success
                       text     = CONV #( ls_msg-msg ) )
            ) TO reported-xlhead.

          ELSEIF ls_msg-msgty = 'E'.
            " Append Error message to UI
            APPEND VALUE #(
              %tky = keys[ 1 ]-%tky " Link to correct record key to trigger UI popup
              %msg = new_message_with_text(
                       severity = if_abap_behv_message=>severity-error
                       text     = CONV #( ls_msg-msg ) )
            ) TO reported-xlhead.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
***    LOOP AT lt_finished INTO DATA(lo_inst).
***           DATA lo_res_parallel TYPE REF TO zcl_jv_parallel.
***            " Assuming 'inst' is the component name holding the object reference
***            lo_res_parallel ?= lo_inst-inst.
***
***            DATA: lv_res_num TYPE char10,
***                  lv_err_msg TYPE string.
***
***            if  lo_res_parallel->wa_log IS NOT INITIAL.
***               " Success Message
***               read TABLE lo_res_parallel->it_po_final into DATA(w_f) INDEX 1.
***               if w_f-belnr is not initial.
***               DATA(lv_success_msg) = |Document { w_f-belnr } created successfully.|.
***               APPEND VALUE #( %msg = new_message_with_text(
***                                         severity = if_abap_behv_message=>severity-success
***                                         text = lv_success_msg )
***                              ) TO reported-xldata.
****               else .
****               read TABLE lo_res_parallel-> into DATA(w_f) INDEX 1.
****               DATA(lv_error_msg) = |Error : {  } |.
****                " Error Message
****                APPEND VALUE #( %msg = new_message_with_text(
****                                         severity = if_abap_behv_message=>severity-error
****                                         text = lv_error_msg )
****                              ) TO reported-header.
***               endif.
***           endif.
***    ENDLOOP.
*      IF lt_excel IS NOT INITIAL .
*
*        INSERT NEW zcl_ins_parallel(  lt_po_details = CORRESPONDING #( lt_excel )  )
*        INTO TABLE lt_poparallel.
*
*        IF lt_poparallel IS NOT INITIAL .
*
*          lo_proc->run_inst(  EXPORTING p_in_tab = lt_poparallel
*                                       p_debug = abap_false
*                              IMPORTING p_out_tab = DATA(lt_finished)  ).
*        ENDIF.
*      ENDIF.

*    ELSE.
*      MODIFY ENTITIES OF ZINS_I_JV_HEAD IN LOCAL MODE
*        ENTITY xlhead
*        UPDATE FROM VALUE #(
*          (
*            %tky                 = lt_file_entity[ 1 ]-%tky  "keys[ 1 ]-%tky
*            filestatus           = 'File is already uploaded , upload different file'
*            %control-filestatus  = if_abap_behv=>mk-on
*          )
*        )
*        MAPPED lt_upd_mapped
*        FAILED lt_upd_failed
*        REPORTED lt_upd_reported.
*    ENDIF.

  ENDMETHOD.

  METHOD fillfilestatus.
  ENDMETHOD.

  METHOD fillselectedstatus.
  ENDMETHOD.

ENDCLASS.
