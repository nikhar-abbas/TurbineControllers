module io

contains

TYPE, PUBLIC :: ControlParameters
    INTEGER(4)                          :: LoggingLevel                 ! 0 = write no debug files, 1 = write standard output .dbg-file, 2 = write standard output .dbg-file and complete avrSWAP-array .dbg2-file
    INTEGER(4)                          :: F_FilterType                 ! 1 = first-order low-pass filter, 2 = second-order low-pass filter
    REAL(4)                             :: F_CornerFreq                 ! Corner frequency (-3dB point) in the first-order low-pass filter, [rad/s]
    REAL(4)                             :: F_Damping                    ! Damping coefficient if F_FilterType = 2, unused otherwise
    REAL(4)                             :: IPC_IntSat                   ! Integrator saturation (maximum signal amplitude contrbution to pitch from IPC)
    REAL(4)                             :: IPC_KI                       ! Integral gain for the individual pitch controller, [-]. 8E-10
    INTEGER(4)                          :: IPC_ControlMode              ! Turn Individual Pitch Control (IPC) for fatigue load reductions (pitch contribution) on = 1/off = 0
    REAL(4)                             :: IPC_omegaLP                  ! Low-pass filter corner frequency for the individual pitch controller, [rad/s].    
    REAL(4)                             :: IPC_aziOffset                ! Phase offset added to the azimuth angle for the individual pitch controller, [rad].
    REAL(4)                             :: IPC_zetaLP                   ! Low-pass filter damping factor for the individual pitch controller, [-].
    INTEGER(4)                          :: PC_GS_n                      ! Amount of gain-scheduling table entries
    REAL(4), DIMENSION(:), ALLOCATABLE  :: PC_GS_angles                 ! Gain-schedule table: pitch angles
    REAL(4), DIMENSION(:), ALLOCATABLE  :: PC_GS_KP                     ! Gain-schedule table: pitch controller kp gains
    REAL(4), DIMENSION(:), ALLOCATABLE  :: PC_GS_KI                     ! Gain-schedule table: pitch controller ki gains
    REAL(4), DIMENSION(:), ALLOCATABLE  :: PC_GS_KD                     ! Gain-schedule table: pitch controller kd gains
    REAL(4), DIMENSION(:), ALLOCATABLE  :: PC_GS_TF                     ! Gain-schedule table: pitch controller tf gains (derivative filter)
    REAL(4)                             :: PC_MaxPit                    ! Maximum physical pitch limit, [rad].
    REAL(4)                             :: PC_MinPit                    ! Minimum physical pitch limit, [rad].
    REAL(4)                             :: PC_MaxRat                    ! Maximum pitch rate (in absolute value) in pitch controller, [rad/s].
    REAL(4)                             :: PC_MinRat                    ! Minimum pitch rate (in absolute value) in pitch controller, [rad/s].
    REAL(4)                             :: PC_RefSpd                    ! Desired (reference) HSS speed for pitch controller, [rad/s].
    REAL(4)                             :: PC_FinePit                   ! Record 5: Below-rated pitch angle set-point (deg) [used only with Bladed Interface]
    REAL(4)                             :: PC_Switch                    ! Angle above lowest minimum pitch angle for switch [rad]
    INTEGER(4)                          :: VS_ControlMode               ! Generator torque control mode in above rated conditions, 0 = constant torque / 1 = constant power
    REAL(4)                             :: VS_GenEff                    ! Generator efficiency mechanical power -> electrical power [-]
    REAL(4)                             :: VS_ArSatTq                   ! Above rated generator torque PI control saturation, [Nm] -- 212900
    REAL(4)                             :: VS_MaxRat                    ! Maximum torque rate (in absolute value) in torque controller, [Nm/s].
    REAL(4)                             :: VS_MaxTq                     ! Maximum generator torque in Region 3 (HSS side), [Nm]. -- chosen to be 10% above VS_RtTq
    REAL(4)                             :: VS_MinTq                     ! Minimum generator (HSS side), [Nm].
    REAL(4)                             :: VS_MinOMSpd                  ! Optimal mode minimum speed, [rad/s]
    REAL(4)                             :: VS_Rgn2K                     ! Generator torque constant in Region 2 (HSS side), N-m/(rad/s)^2
    REAL(4)                             :: VS_RtPwr                     ! Wind turbine rated power [W]
    REAL(4)                             :: VS_RtTq                      ! Rated torque, [Nm].
    REAL(4)                             :: VS_RefSpd                    ! Rated generator speed [rad/s]
    INTEGER(4)                          :: VS_n                         ! Number of controller gains
    REAL(4), DIMENSION(:), ALLOCATABLE  :: VS_KP                        ! Proportional gain for generator PI torque controller, used in the transitional 2.5 region
    REAL(4), DIMENSION(:), ALLOCATABLE  :: VS_KI                        ! Integral gain for generator PI torque controller, used in the transitional 2.5 region
    INTEGER(4)                          :: Y_ControlMode                ! Yaw control mode: (0 = no yaw control, 1 = yaw rate control, 2 = yaw-by-IPC)
    REAL(4)                             :: Y_ErrThresh                  ! Error threshold [rad]. Turbine begins to yaw when it passes this. (104.71975512) -- 1.745329252
    REAL(4)                             :: Y_IPC_IntSat                 ! Integrator saturation (maximum signal amplitude contrbution to pitch from yaw-by-IPC)
    INTEGER(4)                          :: Y_IPC_n                      ! Number of controller gains (yaw-by-IPC)
    REAL(4), DIMENSION(:), ALLOCATABLE  :: Y_IPC_KP                     ! Yaw-by-IPC proportional controller gain Kp
    REAL(4), DIMENSION(:), ALLOCATABLE  :: Y_IPC_KI                     ! Yaw-by-IPC integral controller gain Ki
    REAL(4)                             :: Y_MErrSet                    ! Yaw alignment error, setpoint [rad]
    REAL(4)                             :: Y_omegaLPFast                ! Corner frequency fast low pass filter, 1.0 [Hz]
    REAL(4)                             :: Y_omegaLPSlow                ! Corner frequency slow low pass filter, 1/60 [Hz]
    REAL(4)                             :: Y_Rate                       ! Yaw rate [rad/s]
    
    REAL(4)                             :: PC_RtTq99                    ! 99% of the rated torque value, using for switching between pitch and torque control, [Nm].
    REAL(4)                             :: VS_MaxOMTq                   ! Maximum torque at the end of the below-rated region 2, [Nm]
    REAL(4)                             :: VS_MinOMTq                   ! Minimum torque at the beginning of the below-rated region 2, [Nm]
    REAL(4)                             :: VS_Rgn3Pitch                 ! Pitch angle at which the state machine switches to region 3, [rad].
END TYPE ControlParameters

SUBROUTINE ReadControlParameterFileSub(CntrPar, LocalVar)
        USE DRC_Types, ONLY : ControlParameters, LocalVariables
    
        INTEGER(4), PARAMETER       :: UnControllerParameters = 89
        TYPE(ControlParameters), INTENT(INOUT)  :: CntrPar
        TYPE(LocalVariables), INTENT(IN)        :: LocalVar
        
        OPEN(unit=UnControllerParameters, file='ControllerParameters.in', status='old', action='read')
        
        !------------------- GENERAL CONSTANTS -------------------
        READ(UnControllerParameters, *) CntrPar%LoggingLevel
        READ(UnControllerParameters, *) CntrPar%F_FilterType
        READ(UnControllerParameters, *) CntrPar%F_CornerFreq
        READ(UnControllerParameters, *) CntrPar%F_Damping
        
        !------------------- IPC CONSTANTS -----------------------
        READ(UnControllerParameters, *) CntrPar%IPC_IntSat
        READ(UnControllerParameters, *) CntrPar%IPC_KI
        READ(UnControllerParameters, *) CntrPar%IPC_ControlMode
        READ(UnControllerParameters, *) CntrPar%IPC_omegaLP
        READ(UnControllerParameters, *) CntrPar%IPC_aziOffset
        READ(UnControllerParameters, *) CntrPar%IPC_zetaLP
        
        !------------------- PITCH CONSTANTS -----------------------
        READ(UnControllerParameters, *) CntrPar%PC_GS_n
        ALLOCATE(CntrPar%PC_GS_angles(CntrPar%PC_GS_n))
        READ(UnControllerParameters,*) CntrPar%PC_GS_angles
        
        ALLOCATE(CntrPar%PC_GS_KP(CntrPar%PC_GS_n))
        READ(UnControllerParameters,*) CntrPar%PC_GS_KP
        
        ALLOCATE(CntrPar%PC_GS_KI(CntrPar%PC_GS_n))
        READ(UnControllerParameters,*) CntrPar%PC_GS_KI
        
        ALLOCATE(CntrPar%PC_GS_KD(CntrPar%PC_GS_n))
        READ(UnControllerParameters,*) CntrPar%PC_GS_KD
        
        ALLOCATE(CntrPar%PC_GS_TF(CntrPar%PC_GS_n))
        READ(UnControllerParameters,*) CntrPar%PC_GS_TF
        
        READ(UnControllerParameters, *) CntrPar%PC_MaxPit
        READ(UnControllerParameters, *) CntrPar%PC_MinPit
        READ(UnControllerParameters, *) CntrPar%PC_MaxRat
        READ(UnControllerParameters, *) CntrPar%PC_MinRat
        READ(UnControllerParameters, *) CntrPar%PC_RefSpd
        READ(UnControllerParameters, *) CntrPar%PC_FinePit
        READ(UnControllerParameters, *) CntrPar%PC_Switch
        
        !------------------- TORQUE CONSTANTS -----------------------
        READ(UnControllerParameters, *) CntrPar%VS_ControlMode
        READ(UnControllerParameters, *) CntrPar%VS_GenEff
        READ(UnControllerParameters, *) CntrPar%VS_ArSatTq
        READ(UnControllerParameters, *) CntrPar%VS_MaxRat
        READ(UnControllerParameters, *) CntrPar%VS_MaxTq
        READ(UnControllerParameters, *) CntrPar%VS_MinTq
        READ(UnControllerParameters, *) CntrPar%VS_MinOMSpd
        READ(UnControllerParameters, *) CntrPar%VS_Rgn2K
        READ(UnControllerParameters, *) CntrPar%VS_RtPwr
        READ(UnControllerParameters, *) CntrPar%VS_RtTq
        READ(UnControllerParameters, *) CntrPar%VS_RefSpd
        READ(UnControllerParameters, *) CntrPar%VS_n
        
        ALLOCATE(CntrPar%VS_KP(CntrPar%VS_n))
        READ(UnControllerParameters,*) CntrPar%VS_KP
        
        ALLOCATE(CntrPar%VS_KI(CntrPar%VS_n))
        READ(UnControllerParameters,*) CntrPar%VS_KI
        
        !------------------- YAW CONSTANTS -----------------------
        READ(UnControllerParameters, *) CntrPar%Y_ControlMode
        READ(UnControllerParameters, *) CntrPar%Y_ErrThresh
        READ(UnControllerParameters, *) CntrPar%Y_IPC_IntSat
        READ(UnControllerParameters, *) CntrPar%Y_IPC_n
        
        ALLOCATE(CntrPar%Y_IPC_KP(CntrPar%Y_IPC_n))
        READ(UnControllerParameters,*) CntrPar%Y_IPC_KP
        
        ALLOCATE(CntrPar%Y_IPC_KI(CntrPar%Y_IPC_n))
        READ(UnControllerParameters,*) CntrPar%Y_IPC_KI
        
        READ(UnControllerParameters, *) CntrPar%Y_MErrSet
        READ(UnControllerParameters, *) CntrPar%Y_omegaLPFast
        READ(UnControllerParameters, *) CntrPar%Y_omegaLPSlow
        READ(UnControllerParameters, *) CntrPar%Y_Rate
        
        !------------------- CALCULATED CONSTANTS -----------------------
        CntrPar%PC_RtTq99       = CntrPar%VS_RtTq*0.99
        CntrPar%VS_MinOMTq  = CntrPar%VS_Rgn2K*CntrPar%VS_MinOMSpd**2
        CntrPar%VS_MaxOMTq  = CntrPar%VS_Rgn2K*CntrPar%VS_RefSpd**2
        CntrPar%VS_Rgn3Pitch        = CntrPar%PC_FinePit + CntrPar%PC_Switch
        
        CLOSE(UnControllerParameters)
    END SUBROUTINE ReadControlParameterFileSub

end module