@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'JV POSTING'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZJV_C_XL_USER 
provider contract transactional_query
  as projection on ZINS_I_JV_HEAD
{
  key EndUser,
  key FileId,

      FileStatus,

      @Semantics.largeObject: {
        mimeType: 'Mimetype',
        fileName: 'Filename',

        acceptableMimeTypes: [
          'application/vnd.ms-excel',
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        ],
        contentDispositionPreference: #INLINE
      }
      Attachment,

      @Semantics.mimeType: true
      Mimetype,
      Filename,
      insno,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,

      /* Associations */
      _XLData : redirected to composition child ZC_ACCDOC
}
