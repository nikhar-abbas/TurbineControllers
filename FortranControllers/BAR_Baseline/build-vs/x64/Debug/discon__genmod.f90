        !COMPILER-GENERATED INTERFACE MODULE: Tue Jul 02 11:01:30 2019
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE DISCON__genmod
          INTERFACE 
            SUBROUTINE DISCON(AVRSWAP,AVIFAIL,ACCINFILE,AVCOUTNAME,     &
     &AVCMSG) BIND(C, NAME = 'DISCON')
              REAL(KIND=4), INTENT(INOUT) :: AVRSWAP(*)
              INTEGER(KIND=4), INTENT(INOUT) :: AVIFAIL
              CHARACTER(LEN=1), INTENT(IN) :: ACCINFILE(NINT(AVRSWAP((50&
     &))))
              CHARACTER(LEN=1), INTENT(IN) :: AVCOUTNAME(NINT(AVRSWAP(( &
     &51))))
              CHARACTER(LEN=1), INTENT(INOUT) :: AVCMSG(NINT(AVRSWAP((49&
     &))))
            END SUBROUTINE DISCON
          END INTERFACE 
        END MODULE DISCON__genmod
