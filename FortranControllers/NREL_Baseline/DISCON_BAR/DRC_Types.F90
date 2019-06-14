MODULE DRC_Types

IMPLICIT NONE

TYPE, PUBLIC :: ControlParameters
    ! General Filters
    REAL(4)                           :: CornerFreq_HSS                 ! Corner frequency (-3dB point) in the recursive, single-pole, low-pass filter, Hz. -- !! NJA: Not yet: chosen to be 1/4 the blade edgewise natural frequency ( 1/4 of approx. 1Hz = 0.25Hz = 1.570796rad/s)
    ! Pitch Controller
    REAL(4)                           :: PC_DT                          ! Communication interval for pitch  controller, sec.
    REAL(4)                           :: PC_KI                          ! Integral gain for pitch controller at rated pitch (zero), (-).
    REAL(4)                           :: PC_KK                          ! Pitch angle where the the derivative of the aerodynamic power w.r.t. pitch has increased by a factor of two relative to the derivative at rated pitch (zero), rad.
    REAL(4)                           :: PC_KP                          ! Proportional gain for pitch controller at rated pitch (zero), sec.
    REAL(4)                           :: PC_MaxPit                      ! Maximum pitch setting in pitch controller, rad.
    REAL(4)                           :: PC_MaxRat                      ! Maximum pitch  rate (in absolute value) in pitch  controller, rad/s.
    REAL(4)                           :: PC_MinPit                      ! Minimum pitch setting in pitch controller, rad.
    REAL(4)                           :: PC_RefSpd                      ! Desired (reference) HSS speed for pitch controller, rad/s.
    ! VS Torque Controller
    REAL(4)                           :: VS_CtInSp                      ! Transitional generator speed (HSS side) between regions 1 and 1 1/2, rad/s.
    REAL(4)                           :: VS_DT                          ! Communication interval for torque controller, sec.
    REAL(4)                           :: VS_MaxRat                      ! Maximum torque rate (in absolute value) in torque controller, N-m/s.
    REAL(4)                           :: VS_MaxTq                       ! Maximum generator torque in Region 3 (HSS side), N-m. -- chosen to be 10% above VS_RtTq      = 000000.0 = 43.09355kNm
    Real(4)                           :: VS_RtTq                        ! Rated generator torque, Nm.
    REAL(4)                           :: VS_Rgn2K                       ! Generator torque constant in Region 2 (HSS side), N-m/(rad/s)^2.
    REAL(4)                           :: VS_Rgn2Sp                      ! Transitional generator speed (HSS side) between regions 1 1/2 and 2, rad/s.
    REAL(4)                           :: VS_Rgn3MP                      ! Minimum pitch angle at which the torque is computed as if we are in region 3 regardless of the generator speed, rad. -- chosen to be 1.0 degree above PC_MinPit
    REAL(4)                           :: VS_RtGnSp                      ! Rated generator speed (HSS side), rad/s. -- chosen to be 100% of PC_RefSpd
    REAL(4)                           :: VS_RtPwr                       ! Rated generator generator power in Region 3, Watts. -- chosen to be 5MW divided by the electrical generator efficiency of 94.4%
    REAL(4)                           :: VS_SlPc                        ! Rated generator slip percentage in Region 2 1/2, %.
    ! Region 2.5 Smoothing
    Real(4)                           :: GainBias_Mode                  ! Gain Bias Mode, 0 = no gain bais, 1 = gain bias as defined by David Schlipf, -.
    Real(4)                           :: VS_GainBias                    ! Variable speed torque controller gain bias, (rad/s)/(rad).
    Real(4)                           :: PC_GainBias                    ! Collective pitch controller gain bias, (rad/s)/(Nm).
    Real(4)                           :: CornerFreq_GB                  ! Cornering frequency of first order low pass filter for the gain bias signal, Hz.
    ! Housekeeping
    REAL(4)                           :: OnePlusEps                     ! The number slighty greater than unity in single precision.
END TYPE ControlParameters

TYPE, PUBLIC :: LocalVariables
    ! From avrSWAP
    INTEGER(4)                          :: iStatus
    REAL(4)                             :: Time
    REAL(4)                             :: GenSpeed
    REAL(4)                             :: HorWindV
    REAL(4)                             :: BlPitch(3)
    INTEGER(4)                          :: NumBl
    
    ! Internal controller variables 
    ! Controller Agnostic
    REAL(4)                             :: GenSpeedF                    ! Filtered HSS (generator) speed [rad/s].
    REAL(4)                             :: LastTime                     ! Last time the controller was called, sec.
    REAL(4)                             :: LastTimePC                   ! Last time the pitch  controller was called, sec.
    REAL(4)                             :: LastTimeVS                   ! Last time the torque controller was called, sec.
    ! Pitch Controller
    REAL(4)                             :: PitCom(3)                    ! Commanded pitch of each blade the last time the controller was called, [rad].
    REAL(4)                             :: PitComI                      ! Integral term of command pitch, rad.
    REAL(4)                             :: PitComP                      ! Proportional term of command pitch, rad.
    REAL(4)                             :: PitComT                      ! Total command pitch based on the sum of the proportional and integral terms, rad.
    REAL(4)                             :: SpdErr                       ! Current speed error, rad/s.
    REAL(4)                             :: GK                           ! Current value of the gain correction factor, used in the gain scheduling law of the pitch controller, (-).

    ! Torque Controller
    REAL(4)                             :: GenTrq                       ! Electrical generator torque, [Nm].
    REAL(4)                             :: SpdErr                       ! Current speed error, rad/s.
    REAL(4)                             :: TrqRate                      ! Torque rate based on the current and last torque commands, N-m/s.
    REAL(4)                             :: VS_Slope15                   ! Torque/speed slope of region 1 1/2 cut-in torque ramp , N-m/(rad/s).
    REAL(4)                             :: VS_Slope25                   ! Torque/speed slope of region 2 1/2 induction generator, N-m/(rad/s).
    REAL(4)                             :: VS_SySp                      ! Synchronous speed of region 2 1/2 induction generator, rad/s.
    REAL(4)                             :: VS_TrGnSp                    ! Transitional generator speed (HSS side) between regions 2 and 2 1/2, rad/s.
    ! Region 2.5 Smoothing
    Real(4)                             :: GenSpeedF_VS                 ! Filtered generator speed signal for VS Torque controller, rad/s.
    Real(4)                             :: GenSpeedF_PC                 ! Filtered generator speed signal for collective pitch controller, rad/s.
    Real(4)                             :: DelOmega                     ! Reference generator speed shift, rad/s.
    Real(4)                             :: DelOmegaF                    ! Filtered reference generator speed shift, rad/s.
    Real(4)                             :: Alpha_GB                     ! Current coefficient in the recursive, single-pole, low-pass filter for DelOmega, (-).
END TYPE LocalVariables

! TYPE, PUBLIC :: ObjectInstances   ! NJA - Leaving these out for now,  not sure I like it.
!     INTEGER(4)                          :: instLPF
!     INTEGER(4)                          :: instSecLPF
!     INTEGER(4)                          :: instHPF
!     INTEGER(4)                          :: instNotchSlopes
!     INTEGER(4)                          :: instNotch
!     INTEGER(4)                          :: instPI
! END TYPE ObjectInstances
END MODULE DRC_Types