MODULE ReadSetParameters

    USE, INTRINSIC  :: ISO_C_Binding
    IMPLICIT NONE
        
CONTAINS
    !..............................................................................................................................
    ! Read all constant control parameters from ControllerParameters.in parameter file
    !..............................................................................................................................
    SUBROUTINE ReadControlParameterFileSub(CntrPar, LocalVar)
        USE DRC_Types, ONLY : ControlParameters, LocalVariables
    
        INTEGER(4), PARAMETER       :: UnControllerParameters = 89
        TYPE(ControlParameters), INTENT(INOUT)  :: CntrPar
        TYPE(LocalVariables), INTENT(IN)        :: LocalVar
        
        OPEN(unit=UnControllerParameters, file='ControllerParameters.in', status='old', action='read')
        
        ! ------------------ GENERAL CONSTANTS ------------------
        READ(UnControllerParameters, *) ! Comment line
        ! This is where you would put filter flags and things like that, probably. Or at the top of each controller parameter definitions
        
        ! ------------------ General Filters ------------------
        READ(UnControllerParameters, *) ! Commented Line
        READ(UnControllerParameters, *) CntrPar%CornerFreq_HSS

        ! ------------------ PITCH CONSTANTS ------------------
        READ(UnControllerParameters, *) ! Commented Line
        READ(UnControllerParameters, *) CntrPar%PC_DT
        READ(UnControllerParameters, *) CntrPar%PC_KI
        READ(UnControllerParameters, *) CntrPar%PC_KK
        READ(UnControllerParameters, *) CntrPar%PC_KP
        READ(UnControllerParameters, *) CntrPar%PC_MaxPit
        READ(UnControllerParameters, *) CntrPar%PC_MaxRat
        READ(UnControllerParameters, *) CntrPar%PC_MinPit
        READ(UnControllerParameters, *) CntrPar%PC_RefSpd

        ! NJA - leaving this in to show you how to read a lookup table
        ! READ(UnControllerParameters, *) CntrPar%PC_GS_n
        ! ALLOCATE(CntrPar%PC_GS_angles(CntrPar%PC_GS_n))
        ! READ(UnControllerParameters,*) CntrPar%PC_GS_angles

        
        ! ------------------ TORQUE CONSTANTS ------------------
        READ(UnControllerParameters, *) CntrPar%VS_DT
        READ(UnControllerParameters, *) CntrPar%VS_CtInSp
        READ(UnControllerParameters, *) CntrPar%VS_MaxRat
        READ(UnControllerParameters, *) CntrPar%VS_MaxTq
        READ(UnControllerParameters, *) CntrPar%VS_RtTq
        READ(UnControllerParameters, *) CntrPar%VS_Rgn2K
        READ(UnControllerParameters, *) CntrPar%VS_Rgn2Sp
        READ(UnControllerParameters, *) CntrPar%VS_Rgn3MP
        READ(UnControllerParameters, *) CntrPar%VS_RtGnSp
        READ(UnControllerParameters, *) CntrPar%VS_RtPwr
        READ(UnControllerParameters, *) CntrPar%VS_SlPc

        ! ------------------ Region 2.5 Smoothing ------------------
        READ(UnControllerParameters, *) CntrPar%GainBias_Mode
        READ(UnControllerParameters, *) CntrPar%VS_GainBias
        READ(UnControllerParameters, *) CntrPar%PC_GainBias
        READ(UnControllerParameters, *) CntrPar%CornerFreq_GB
        
        !------------------- Housekeeping -----------------------
        CntrPar%OnePlusEps  = 1.0 + EPSILON(OnePlusEps)     ! The number slighty greater than unity in single precision.
        CntrPar%R2D         = 57.295780                     ! Factor to convert radians to degrees.
        CntrPar%RPS2RPM     =  9.5492966                    ! Factor to convert radians per second to revolutions per minute.
        
        CLOSE(UnControllerParameters)
    END SUBROUTINE ReadControlParameterFileSub
    
    SUBROUTINE ReadAvrSWAP(avrSWAP, LocalVar)
        USE DRC_Types, ONLY : LocalVariables
    
        REAL(C_FLOAT), INTENT(INOUT)    :: avrSWAP(*)   ! The swap array, used to pass data to, and receive data from, the DLL controller.
        TYPE(LocalVariables), INTENT(INOUT) :: LocalVar
        
        ! Load variables from calling program (See Appendix A of Bladed User's Guide):
        LocalVar%iStatus        = NINT(avrSWAP(1))
        LocalVar%NumBl          = NINT(avrSWAP(61))
        LocalVar%Time           = avrSWAP(2)
        LocalVar%GenSpeed       = avrSWAP(20)
        LocalVar%HorWindV       = avrSWAP(27)
        LocalVar%BlPitch(1)     = avrSWAP(4)
        LocalVar%BlPitch(2)     = avrSWAP(33)
        LocalVar%BlPitch(3)     = avrSWAP(34)
    END SUBROUTINE ReadAvrSWAP
    
    SUBROUTINE Assert(LocalVar, CntrPar, avrSWAP, aviFAIL, ErrMsg, size_avcMSG)
        USE, INTRINSIC  :: ISO_C_Binding
        USE DRC_Types, ONLY : LocalVariables, ControlParameters
    
        IMPLICIT NONE

            ! Inputs
        TYPE(ControlParameters), INTENT(IN)     :: CntrPar
        TYPE(LocalVariables), INTENT(IN)        :: LocalVar
        INTEGER(4), INTENT(IN)                  :: size_avcMSG
        REAL(C_FLOAT), INTENT(IN)               :: avrSWAP(*)                       ! The swap array, used to pass data to, and receive data from, the DLL controller.
        
            ! Outputs
        INTEGER(C_INT), INTENT(OUT)             :: aviFAIL                          ! A flag used to indicate the success of this DLL call set as follows: 0 if the DLL call was successful, >0 if the DLL call was successful but cMessage should be issued as a warning messsage, <0 if the DLL call was unsuccessful or for any other reason the simulation is to be stopped at this point with cMessage as the error message.
        CHARACTER(size_avcMSG-1), INTENT(OUT)   :: ErrMsg                           ! a Fortran version of the C string argument (not considered an array here) [subtract 1 for the C null-character]
        
            ! Local
        
        !..............................................................................................................................
        ! Check validity of input parameters:
        !..............................................................................................................................
        
        IF ( CornerFreq_HSS <= 0.0 )  THEN
      aviFAIL = -1
      ErrMsg  = 'CornerFreq_HSS must be greater than zero.'
   ENDIF

   IF ( CntrPar%VS_DT     <= 0.0 )  THEN
      aviFAIL = -1
      ErrMsg  = 'VS_DT must be greater than zero.'
   ENDIF

   IF ( CntrPar%VS_CtInSp <  0.0 )  THEN
      aviFAIL = -1
      ErrMsg  = 'VS_CtInSp must not be negative.'
   ENDIF

   IF ( CntrPar%VS_Rgn2Sp <= CntrPar%VS_CtInSp )  THEN
      aviFAIL = -1
      ErrMsg  = 'VS_Rgn2Sp must be greater than VS_CtInSp.'
   ENDIF

   IF ( CntrPar%VS_TrGnSp <  CntrPar%VS_Rgn2Sp )  THEN
      aviFAIL = -1
      ErrMsg = 'VS_TrGnSp must not be less than VS_Rgn2Sp.'
   ENDIF

   IF ( CntrPar%VS_SlPc   <= 0.0 )  THEN
      aviFAIL = -1
      ErrMsg  = 'VS_SlPc must be greater than zero.'
   ENDIF

   IF ( CntrPar%VS_MaxRat <= 0.0 )  THEN
      aviFAIL =  -1
      ErrMsg  = 'VS_MaxRat must be greater than zero.'
   ENDIF

   IF ( CntrPar%VS_RtPwr  <  0.0 )  THEN
      aviFAIL = -1
      ErrMsg  = 'VS_RtPwr must not be negative.'
   ENDIF

   IF ( CntrPar%VS_Rgn2K  <  0.0 )  THEN
      aviFAIL = -1
      ErrMsg  = 'VS_Rgn2K must not be negative.'
   ENDIF

   IF ( CntrPar%VS_Rgn2K*CntrPar%VS_RtGnSp*CntrPar%VS_RtGnSp > CntrPar%VS_RtPwr/CntrPar%VS_RtGnSp )  THEN
      aviFAIL = -1
      ErrMsg  = 'VS_Rgn2K*VS_RtGnSp^2 must not be greater than VS_RtPwr/VS_RtGnSp.'
   ENDIF

   IF ( CntrPar%VS_MaxTq < CntrPar%VS_RtPwr/CntrPar%VS_RtGnSp )  THEN
      aviFAIL = -1
      ErrMsg  = 'VS_RtPwr/VS_RtGnSp must not be greater than VS_MaxTq.'
   ENDIF

   IF ( CntrPar%PC_DT <= 0.0 )  THEN
      aviFAIL = -1
      ErrMsg  = 'PC_DT must be greater than zero.'
   ENDIF

   IF ( CntrPar%PC_KI <= 0.0 )  THEN
      aviFAIL = -1
      ErrMsg  = 'PC_KI must be greater than zero.'
   ENDIF

   IF ( CntrPar%PC_KK <= 0.0 )  THEN
      aviFAIL = -1
      ErrMsg  = 'PC_KK must be greater than zero.'
   ENDIF

   IF ( CntrPar%PC_RefSpd <= 0.0 )  THEN
      aviFAIL = -1
      ErrMsg  = 'PC_RefSpd must be greater than zero.'
   ENDIF
   
   IF ( CntrPar%PC_MaxRat <= 0.0 )  THEN
      aviFAIL = -1
      ErrMsg  = 'PC_MaxRat must be greater than zero.'
   ENDIF

   IF ( CntrPar%PC_MinPit >= CntrPar%PC_MaxPit )  THEN
      aviFAIL = -1
      ErrMsg  = 'PC_MinPit must be less than PC_MaxPit.'
   ENDIF

    END SUBROUTINE Assert
    
    SUBROUTINE SetParameters(avrSWAP, aviFAIL, ErrMsg, size_avcMSG, CntrPar, LocalVar, objInst)
        USE DRC_Types, ONLY : ControlParameters, LocalVariables, ObjectInstances
        
        INTEGER(4), INTENT(IN)                  :: size_avcMSG
        TYPE(ControlParameters), INTENT(INOUT)  :: CntrPar
        TYPE(LocalVariables), INTENT(INOUT)     :: LocalVar
        TYPE(ObjectInstances), INTENT(INOUT)    :: objInst
        
        REAL(C_FLOAT), INTENT(INOUT)                :: avrSWAP(*)   ! The swap array, used to pass data to, and receive data from, the DLL controller.
        INTEGER(C_INT), INTENT(OUT)                 :: aviFAIL      ! A flag used to indicate the success of this DLL call set as follows: 0 if the DLL call was successful, >0 if the DLL call was successful but cMessage should be issued as a warning messsage, <0 if the DLL call was unsuccessful or for any other reason the simulation is to be stopped at this point with cMessage as the error message.
        CHARACTER(size_avcMSG-1), INTENT(OUT)       :: ErrMsg       ! a Fortran version of the C string argument (not considered an array here) [subtract 1 for the C null-character]
        INTEGER(4)                      :: K            ! Index used for looping through blades.
        
        ! Set aviFAIL to 0 in each iteration:
        aviFAIL = 0
        
        ! Set unused outputs to zero (See Appendix A of Bladed User's Guide):
        avrSWAP(36) = 0.0 ! Shaft brake status: 0=off
        avrSWAP(41) = 0.0 ! Demanded yaw actuator torque
        avrSWAP(46) = 0.0 ! Demanded pitch rate (Collective pitch)
        avrSWAP(65) = 0.0 ! Number of variables returned for logging
        avrSWAP(72) = 0.0 ! Generator start-up resistance
        avrSWAP(79) = 0.0 ! Request for loads: 0=none
        avrSWAP(80) = 0.0 ! Variable slip current status
        avrSWAP(81) = 0.0 ! Variable slip current demand
        
        ! Read any External Controller Parameters specified in the User Interface
        !   and initialize variables:
        IF (LocalVar%iStatus == 0)  THEN  ! .TRUE. if we're on the first call to the DLL
            
                ! Inform users that we are using this user-defined routine:
            aviFAIL = 1
            ErrMsg   = 'Running with torque and pitch control of the NREL Baseline '// &
              'wind turbine controller logic from DISCON.dll as originally '// &
              'written by J. Jonkman of NREL/NWTC. The logic has been modified ' // &
              'by Nikhar Abbas to include region 2.5 smoothing as developed by ' // &
              'Sowento energy. The controller has been tuned for use on the BAR.'
 
            CALL ReadControlParameterFileSub(CntrPar, LocalVar)
            
            ! Initialize testValue (debugging variable)
            LocalVar%TestType = 0

            ! Initialize the SAVEd variables:
            ! NOTE: LocalVar%VS_LastGenTrq, though SAVEd, is initialized in the torque controller
            ! below for simplicity, not here.
            LocalVar%GenSpeedF  = LocalVar%GenSpeed                        ! This will ensure that generator speed filter will use the initial value of the generator speed on the first pass
            LocalVar%PitCom     = LocalVar%BlPitch                         ! This will ensure that the variable speed controller picks the correct control region and the pitch controller picks the correct gain on the first call
            LocalVar%GK         = 1.0/( 1.0 + LocalVar%PitCom(1)/CntrPar%PC_KK )   ! This will ensure that the pitch angle is unchanged if the initial SpdErr is zero
            LocalVar%IntSpdErr  = LocalVar%PitCom(1)/(LocalVar%GK*CntrPar%PC_KI )          ! This will ensure that the pitch angle is unchanged if the initial SpdErr is zero
            
            LocalVar%LastTime   = LocalVar%Time                            ! This will ensure that generator speed filter will use the initial value of the generator speed on the first pass
            LocalVar%LastTimePC = LocalVar%Time - CntrPar%PC_DT                    ! This will ensure that the pitch  controller is called on the first pass 
   
            CALL Assert(LocalVar, CntrPar, avrSWAP, aviFAIL, ErrMsg, size_avcMSG)
            
        ENDIF
    END SUBROUTINE SetParameters
END MODULE ReadSetParameters