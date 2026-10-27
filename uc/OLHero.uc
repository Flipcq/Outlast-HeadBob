class OLHero extends OLPawn
    native
    config(Game)
    hidecategories(Navigation);

enum IKTargetType
{
    IKTT_DoorKnob,                  // 0
    IKTT_CSAPropDestination,        // 1
    IKTT_Other,                     // 2
    IKTT_MAX                        // 3
};

enum CornerPeekPosition
{
    CPP_Left,                       // 0
    CPP_Right,                      // 1
    CPP_MiddleLeft,                 // 2
    CPP_MiddleRight,                // 3
    CPP_MAX                         // 4
};

enum ECamcorderMode
{
    CCM_Default,                    // 0
    CCM_PoweredNightVision,         // 1
    CCM_NightVision,                // 2
    CCM_MAX                         // 3
};

enum ECamcorderState
{
    CCS_Inactive,                   // 0
    CCS_Active,                     // 1
    CCS_Raising,                    // 2
    CCS_Lowering,                   // 3
    CCS_ReloadingActive,            // 4
    CCS_ReloadingInactive,          // 5
    CCS_MAX                         // 6
};

enum NVGlitchType
{
    NVGT_SuddenDrop,                // 0
    NVGT_SlowDrop,                  // 1
    NVGT_Buzz,                      // 2
    NVGT_LastBreath,                // 3
    NVGT_MAX                        // 4
};

enum ELedgeTransitionType
{
    LTT_LeftInside,                 // 0
    LTT_LeftOutside,                // 1
    LTT_RightInside,                // 2
    LTT_RightOutside,               // 3
    LTT_MAX                         // 4
};

enum ELedgeClimbType
{
    LCT_ClimbUpToStand,             // 0
    LCT_ClimbUpToCrouch,            // 1
    LCT_ClimbOverToFalling,         // 2
    LCT_ClimbOverToStand,           // 3
    LCT_MAX                         // 4
};

enum ESqueezeTransitionType
{
    STT_Left_Facing,                // 0
    STT_Left_Back,                  // 1
    STT_Right_Facing,               // 2
    STT_Right_Back,                 // 3
    STT_MAX                         // 4
};

enum EDoorOpeningType
{
    DOT_LeftPush,                   // 0
    DOT_LeftPull,                   // 1
    DOT_RightPush,                  // 2
    DOT_RightPull,                  // 3
    DOT_MAX                         // 4
};

enum EDoorPartialOpenType
{
    DPOT_LeftPush,                  // 0
    DPOT_LeftPull,                  // 1
    DPOT_LeftSwipe,                 // 2
    DPOT_RightPush,                 // 3
    DPOT_RightPull,                 // 4
    DPOT_RightSwipe,                // 5
    DPOT_MAX                        // 6
};

enum EDoorClosingType
{
    DCT_LeftFront,                  // 0
    DCT_LeftSide,                   // 1
    DCT_LeftBack,                   // 2
    DCT_LeftInside,                 // 3
    DCT_RightFront,                 // 4
    DCT_RightSide,                  // 5
    DCT_RightBack,                  // 6
    DCT_RightInside,                // 7
    DCT_MAX                         // 8
};

enum EEnemyType
{
    ET_Soldier,                     // 0
    ET_Generic,                     // 1
    ET_Surgeon,                     // 2
    ET_Swarm,                       // 3
    ET_Other,                       // 4
    ET_Groom,                       // 5
    ET_Cannibal,                    // 6
    ET_MAX                          // 7
};

enum EHeroBodySetup
{
    HBS_Normal,                     // 0
    HBS_NoProxy,                    // 1
    HBS_CamcorderRaised,            // 2
    HBS_CamcorderRaisedNoShadow,    // 3
    HBS_CamcorderVisible,           // 4
    HBS_MAX                         // 5
};

struct native HandIKData
{
    var bool bActive;
    var OLHero.IKTargetType IKTarget;
    var float StartTime;
    var float Duration;
    var float FadeInTime;
    var float FadeOutTime;
    var Vector EffectorOffset;

    structdefaultproperties
    {
        bActive=false
        IKTarget=IKTargetType.IKTT_DoorKnob
        StartTime=0.0000000
        Duration=0.0000000
        FadeInTime=0.0000000
        FadeOutTime=0.0000000
        EffectorOffset=(X=0.0000000,Y=0.0000000,Z=0.0000000)
    }
};

struct native CornerPeekData
{
    var OLCornerMarker CornerMarker;
    var OLHero.CornerPeekPosition PeekPosition;
    var Vector CornerLocation;
    var Vector FwdDir;
    var Vector SideDir;
    var bool bRoundedCorner;
    var float IKStrength;
    var float LastInterpActivatedTime;
    var float LastDisconnectTime;
    var bool bDisconnecting;
    var Vector AnchorPos;
    var Quat AnchorRot;
    var Vector JointTargetPos;

    structdefaultproperties
    {
        CornerMarker=none
        PeekPosition=CornerPeekPosition.CPP_Left
        CornerLocation=(X=0.0000000,Y=0.0000000,Z=0.0000000)
        FwdDir=(X=0.0000000,Y=0.0000000,Z=0.0000000)
        SideDir=(X=0.0000000,Y=0.0000000,Z=0.0000000)
        bRoundedCorner=false
        IKStrength=0.0000000
        LastInterpActivatedTime=0.0000000
        LastDisconnectTime=0.0000000
        bDisconnecting=false
        AnchorPos=(X=0.0000000,Y=0.0000000,Z=0.0000000)
        AnchorRot=(X=0.0000000,Y=0.0000000,Z=0.0000000,W=0.0000000)
        JointTargetPos=(X=0.0000000,Y=0.0000000,Z=0.0000000)
    }
};

struct native AttachmentData
{
    var export editinline PrimitiveComponent AttachedComp;
    var bool bHideWhenDone;
    var float BlendInTime;
    var float BlendOutTime;
    var float Duration;
    var Vector PositionOffset;
    var Rotator RotationOffset;
    var bool bActive;
    var bool bAttached;
    var float StartTimestamp;
    var Vector BlendStartPos;
    var Quat BlendStartRot;

    structdefaultproperties
    {
        AttachedComp=none
        bHideWhenDone=false
        BlendInTime=0.0000000
        BlendOutTime=0.0000000
        Duration=0.0000000
        PositionOffset=(X=0.0000000,Y=0.0000000,Z=0.0000000)
        RotationOffset=(Pitch=0,Yaw=0,Roll=0)
        bActive=false
        bAttached=false
        StartTimestamp=0.0000000
        BlendStartPos=(X=0.0000000,Y=0.0000000,Z=0.0000000)
        BlendStartRot=(X=0.0000000,Y=0.0000000,Z=0.0000000,W=0.0000000)
    }
};

struct native CameraParameters
{
    var float MinYaw;
    var float MaxYaw;
    var float MinPitchWS;
    var float MaxPitchWS;
    var float MinPitchCS;
    var float MaxPitchCS;

    structdefaultproperties
    {
        MinYaw=0.0000000
        MaxYaw=0.0000000
        MinPitchWS=0.0000000
        MaxPitchWS=0.0000000
        MinPitchCS=0.0000000
        MaxPitchCS=0.0000000
    }
};

struct native NVGlitchData
{
    var bool bGlitching;
    var float CurrentLevel;
    var float NextGlitchTime;
    var float StartTime;
    var OLHero.NVGlitchType GlitchType;
    var float TargetLevel;
    var float Duration;

    structdefaultproperties
    {
        bGlitching=false
        CurrentLevel=0.0000000
        NextGlitchTime=0.0000000
        StartTime=0.0000000
        GlitchType=NVGlitchType.NVGT_SuddenDrop
        TargetLevel=0.0000000
        Duration=0.0000000
    }
};

struct native LocomotionModeParameters
{
    var GameplayParams GP;
    var float NeckOffsetSide;
    var float NeckOffsetFwd;

    structdefaultproperties
    {
        GP=(RMM=ERootMotionMode.RMM_Ignore,CameraMode=CameraRotationMode.CRM_UserControlled,MinYaw=0.0000000,MaxYaw=0.0000000,MinPitchWS=-84.0000000,MaxPitchWS=70.0000000,MinPitchCS=-84.0000000,MaxPitchCS=84.0000000,ViewLimitsApproachCoeff=0.9900000,FOVOverride=-1.0000000,DisableCollisions=false,IgnorePawnCollisions=false,CollisionHeight=-1.0000000,CollisionRadius=-1.0000000,Physics=EPhysics.PHYS_Custom,BothHandsNeeded=false)
        NeckOffsetSide=0.0000000
        NeckOffsetFwd=0.0000000
    }
};

struct native AIPositionPoint
{
    var Vector Location;
    var Vector LocationOnNavMesh;
    var array<OLEnemyPawn> PawnsOccupying;
    var bool bValid;

    structdefaultproperties
    {
        Location=(X=0.0000000,Y=0.0000000,Z=0.0000000)
        LocationOnNavMesh=(X=0.0000000,Y=0.0000000,Z=0.0000000)
        PawnsOccupying=none
        bValid=false
    }
};

struct native AIPositionPawnInfo
{
    var OLEnemyPawn Enemy;
    var int PointIndex;
    var float TimeToNextChange;

    structdefaultproperties
    {
        Enemy=none
        PointIndex=0
        TimeToNextChange=0.0000000
    }
};

var OLPlayerController OLPC;
var OLHero DefaultHero;
var Vector CharForward;
var Vector EyeForward;
var transient array<OLLedgeMarker> CachedMarkers;
var transient array<OLHidingSpot> CachedHidingSpots;
var transient array<OLDoor> CachedDoors;
var transient array<OLBed> CachedBeds;
var transient array<OLPickableObject> CachedPickables;
var transient array<OLLadderMarker> CachedLadders;
var transient array<OLCSA> CachedCSAs;
var transient array<OLScareMoment> CachedScares;
var transient array<OLPushableObject> CachedPushables;
var transient array<OLCornerMarker> CachedCorners;
var transient array<OLHeatMarker> CachedHeatMarkers;
var transient array<OLRecordingMarker> CachedRecordingMarkers;
var transient array<OLPreferredPathMarker> CachedPreferredPathMarkers;
var transient array<Light> CachedLights;
var transient Vector CachedObjectsPos;
var native transient array<Pointer> CachedLevelList;
var export editinline SkeletalMeshComponent ShadowProxy;
var export editinline StaticMeshComponent HeadMesh;
var export editinline SkeletalMeshComponent CameraMesh;
var export editinline SkeletalMeshComponent CameraMeshShadowProxy;
var export editinline ParticleSystemComponent BloodEffect;
var export editinline ParticleSystemComponent DeathParticles;
var export editinline ParticleSystemComponent DecapitatedBloodEffect;
var export editinline ParticleSystemComponent RainEffect;
var export editinline ParticleSystemComponent WaterFootstepParticlesLeft;
var export editinline ParticleSystemComponent WaterFootstepParticlesRight;
var export editinline ParticleSystemComponent WaterSplashParticles;
var export editinline ParticleSystemComponent GenericCameraEffect;
var export editinline SpotLightComponent NVLightPowered;
var export editinline SpotLightComponent NVLightDefault;
var export editinline SpotLightComponent DarkLight;
var export editinline PointLightComponent CamcorderScreenLight;
var SkeletalMesh FingerlessMesh;
var SkeletalMesh ITTechMesh;
var SkeletalMesh PrisonerMesh;
var MaterialInstanceConstant FootstepDecalMatL1;
var MaterialInstanceConstant FootstepDecalMatL2;
var MaterialInstanceConstant FootstepDecalMatR1;
var MaterialInstanceConstant FootstepDecalMatR2;
var MaterialInstanceConstant FootstepBarefeetDecalMatL1;
var MaterialInstanceConstant FootstepBarefeetDecalMatL2;
var MaterialInstanceConstant FootstepBarefeetDecalMatR1;
var MaterialInstanceConstant FootstepBarefeetDecalMatR2;
var MaterialInstanceConstant CameraScreenMat;
var name CameraScreenParamName;
var OLAnimNodeSlot ShadowProxyFullBodyAnimSlot;
var OLAnimCustomBlend ShadowProxyCustomBlendNode;
var OLAnimCustomBlend UpperBodyBlendNode;
var OLAnimCustomBlend ShadowProxyUpperBodyBlendNode;
var AnimNodeSlot RightArmAnimSlot;
var AnimNodeSlot ShadowProxyRightArmAnimSlot;
var AnimNodeSlot LeftArmAnimSlot;
var AnimNodeSlot ShadowProxyLeftArmAnimSlot;
var OLAnimBlendByPosture BlendByPostureWalkingAnimNode;
var OLAnimBlendByPosture BlendByPostureFallingAnimNode;
var OLAnimBlendByLocomotionMode LocomotionAnimNode;
var OLAnimConstrainedMovement LedgeHangAnimNode;
var OLAnimConstrainedMovement ShadowProxyLedgeHangAnimNode;
var OLAnimConstrainedMovement LedgeWalkAnimNode;
var OLAnimConstrainedMovement ShadowProxyLedgeWalkAnimNode;
var OLAnimConstrainedMovement SqueezeAnimNode;
var OLAnimConstrainedMovement ShadowProxySqueezeAnimNode;
var OLAnimMultiCycleConstrainedMovement LadderAnimNode;
var OLAnimMultiCycleConstrainedMovement ShadowProxyLadderAnimNode;
var OLAnimDoorInteraction DoorAnimNode;
var OLAnimDoorInteraction ShadowProxyDoorAnimNode;
var AnimNodeBlendPerBone LeftArmWallContactFilterNode;
var AnimNodeBlendPerBone ShadowProxyLeftArmWallContactFilterNode;
var AnimNodeSequence LeftArmWallContactAnimSequence;
var AnimNodeSequence ShadowProxyLeftArmWallContactAnimSequence;
var OLAnimPeeking PeekingAnimNode;
var OLAnimPeeking ShadowProxyPeekingAnimNode;
var AnimNodeSequence BedAnimNode;
var AnimNodeSequence ShadowProxyBedAnimNode;
var AnimNodeBlendPerBone LeftFootPlacementNode;
var AnimNodeBlendPerBone ShadowProxyLeftFootPlacementNode;
var AnimNodeBlendPerBone RightFootPlacementNode;
var AnimNodeBlendPerBone ShadowProxyRightFootPlacementNode;
var OLAnimStruggleCycle StruggleAnimNode;
var OLAnimStruggleCycle ShadowProxyStruggleAnimNode;
var OLAnimCrouchedTurnOnSpot CrouchTurnOnSpotAnimNode;
var OLAnimCrouchedTurnOnSpot ShadowProxyCrouchTurnOnSpotAnimNode;
var OLAnimParrying ParryingAnimNode;
var OLAnimParrying ShadowProxyParryingAnimNode;
var OLAnimBlendByLeaning LeanStandingAnimNode;
var OLAnimBlendByLeaning LeanCrouchedAnimNode;
var SkelControlLimb ShadowProxyLeftHandIK;
var SkelControlLimb ShadowProxyRightHandIK;
var SkelControlSingleBone HiddenRightArmControl;
var SkelControlSingleBone HiddenLeftArmControl;
var SkelControlBase LeftForeTwistControl;
var SkelControlBase ShadowProxyLeftForeTwistControl;
var SkelControlBase LeftForeTwist1Control;
var SkelControlBase ShadowProxyLeftForeTwist1Control;
var SkelControlBase LeftUpArmTwistControl;
var SkelControlBase ShadowProxyLeftUpArmTwistControl;
var SkelControlBase RightForeTwistControl;
var SkelControlBase ShadowProxyRightForeTwistControl;
var SkelControlBase RightUpArmTwistControl;
var SkelControlBase ShadowProxyRightUpArmTwistControl;
var SkelControlBase ShadowProxyRightClavicleFixup;
var bool bLeftHandIKActive;
var bool bRightHandIKActive;
var bool bShouldHideLeftHandDuringSM;
var bool bShouldHideRightHandDuringSM;
var bool bMustCrouchAfterSpecialMove;
var bool bForcedCrouch;
var bool bLeaningLeftPushing;
var bool bLeaningRightPushing;
var bool bWantToRun;
var bool bIsGhost;
var bool bPlayingRunSnd;
var bool bElectricGlitchActive;
var bool bElectrified;
var bool bHeatShielding;
var bool bParrying;
var bool bLimping;
var bool bHobbling;
var bool bCamcorderDesired;
var bool bLastCinematicModeDisabledCamcorder;
var bool bBothHandsNeeded;
var bool bPlayingNVGlitchSound;
var bool bRainEffectDesired;
var bool bCameraCracked;
var bool bOverrideDarkLight;
var bool bCameraEffectActive;
var bool bBlockConstrainedMovement;
var bool bKillConstrainedMovement;
var bool bWantLookBack;
var bool bLeftAnim;
var bool bBackAnim;
var bool bExitLadderLeftHand;
var bool bLookingBackLeftSide;
var bool bRunningTraversalMove;
var bool bApplyLandingPenalty;
var bool bJumping;
var bool bPushingFromBackEdge;
var bool bEnterLedgeWalkAfterStruggle;
var bool bStartingSpecialMove;
var bool bJumpFromLedgeWalkWithVelocity;
var bool bPickupCrouched;
var bool bDoorStartingRatioReached;
var bool bQuietDoorInteraction;
var bool MovingNoiseActive;
var bool bWasUnder;
var float MeshZOffset;
var float MeshXOffset;
var float LastFrameMeshZOffset;
var HandIKData LeftHandIKData;
var CornerPeekData CornerPeek;
var float LastValidCornerPeekTime;
var OLCornerMarker LastValidCornerMarker;
var OLHero.CornerPeekPosition LastValidCornerPeekPosition;
var OLHero.ECamcorderMode CamcorderMode;
var OLHero.ECamcorderState CamcorderState;
var OLHero.ELedgeTransitionType ActiveLedgeTransitionType;
var OLHero.ELedgeClimbType LedgeClimbType;
var OLHero.ESqueezeTransitionType SqueezeTransitionType;
var OLHero.EDoorOpeningType DoorOpeningType;
var OLHero.EDoorPartialOpenType DoorPartialOpenType;
var OLHero.EDoorClosingType DoorClosingType;
var OLHero.EEnemyType EnemyType;
var OLEnemyPawn.EWeaponType EnemyWeapon;
var OLHero.EHeroBodySetup BodySetup;
var AttachmentData ActiveAttachment;
var float CurrentLean;
var float LastLeanSndTime;
var float LastFootstepTime;
var float LargeSlopeStartedTime;
var int RemainingBloodyFootsteps;
var OLHeroCamera Camera;
var name LeftHandBoneName;
var name LeftHandAuxBoneName;
var name RightHandAuxBoneName;
var Vector EyeLocation;
var Rotator EyeRotation;
var float CurrentFOV;
var Matrix CameraCompSpace;
var CameraParameters CamParams;
var float LastDamageTime;
var Class<OLDmgType> LastDamageType;
var float LastScriptedDamageEffectTime;
var float PreciseHealth;
var float ElectricEffectStartTime;
var float NextElectricHurtSoundTime;
var float ElectricGlitchStartTime;
var float ElectricGlitchMaxIntensity;
var float ElectricGlitchDuration;
var float ElectricGlitchFrequency;
var float TimeOfDeath;
var float HeatDistance;
var float LastHeatDamageTime;
var float LastElectricDamageTime;
var float CurrentHeatBlur;
var float HobblingIntensity;
var float TargetHobblingIntensity;
var float CamcorderDisabledEndTime;
var float LastCamcorderSwitchTime;
var float CurrentBatterySetEnergy;
var float CurrentCamcorderZoomFactor;
var float TargetCamcorderZoomFactor;
var float NVLightInterpFactor;
var float LastRainEffectActiveTime;
var float CurrentDarkLightRadius;
var float CurrentDarkLightBrightness;
var float DarkLightOverrideBrightness;
var float DarkLightOverrideRadius;
var float CameraEffectEndTime;
var float CameraEffectPlaneDist;
var float OverriddenMinCamcorderFOV;
var NVGlitchData NVGlitch;
var Vector DesiredMoveDirection;
var Vector ExternalImpulse;
var float LedgeHangIdleStartTime;
var float WalkSpeed;
var float RunSpeed;
var float CurrentRunSpeed;
var float InputMovementScaling;
var LocomotionModeParameters LocomotionModeParams[ELocomotionMode];
var OLSeqAct_HeroControl HeroControl;
var OLSqueezeVolume ActiveSqueeze;
var OLLedgeMarker ActiveLedge;
var OLDoor ActiveDoor;
var OLLadderMarker ActiveLadder;
var OLPickableObject ActivePickup;
var OLHidingSpot ActiveLocker;
var OLBed ActiveBed;
var OLCSA ActiveCSA;
var OLPushableObject ActivePushable;
var float SpecialMoveBlendAlpha;
var float SpecialMoveTargetYaw;
var float EnterBedZ;
var float LastCompletedDoorInteractionTime;
var float LastActiveLedgeTimestamp;
var float LastActiveLedgeZ;
var float LastActiveLadderTimestamp;
var float LastSpecialMoveFinishedTime;
var float LastClimbUpObstacleFinishedTime;
var float RunStartedTime;
var float LastLandingTimestamp;
var float SpecialMoveStalledTimestamp;
var float FallingStartedTime;
var float LastEnterLookBackTime;
var float DoorInteractionStartingRatio;
var float DoorSlowClosingAnimStartTime;
var float MovingNoiseTimer;
var array<AIPositionPoint> AIPositionPoints;
var array<AIPositionPawnInfo> AIPositionPawns;
var int LastAIPositionChecked;
var const float NumAIPositions;
var const float AIPositionDistance;
var const float AIPositionLayerBuffer;
var const int NumAIPositionsPerSidePerPawn;
var const int NumAIPositionsToCheckPerFrame;
var Vector AvgVelocity;
var array<Vector2D> AvgVelPoints;
var float AvgVelocityTimer;
var const float NumAvgVelPoints;
var const float AvgVelPointLength;
var config name FirstFingerlessCheckpoint;
var config name ShatteredCameraGlassCheckpoint;
var config name ITUniformCheckpoint;
var config name PrisonerUniformCheckpoint;
var config float NormalWalkSpeed;
var config float NormalRunSpeed;
var config float CrouchedSpeed;
var config float ElectrifiedSpeed;
var config float WaterWalkSpeed;
var config float WaterRunSpeed;
var config float LimpingWalkSpeed;
var config float HobblingWalkSpeed;
var config float HobblingRunSpeed;
var config float SpeedPenaltyBackwards;
var config float SpeedPenaltyStrafe;
var config float ForwardSpeedForJumpWalking;
var config float ForwardSpeedForJumpRunning;
var config float JumpClearanceWalking;
var config float JumpClearanceRunning;
var config float LandingPenaltyDuration;
var config float LandingSpeedModifier;
var config float ElectrifiedJumpDelay;
var config float ExternalImpulseDecelCoeff;
var config float ExternalImpulseMinVel;
var config float ExternalImpulseMaxVel;
var config float ExternalImpulseMaxVelCrouched;
var config float FallSpeedForDamage;
var config float FallSpeedForDeath;
var config float FallDamageExponent;
var config float DefaultFOV;
var config float RunningFOV;
var config float FOVApproachCoeffOpening;
var config float FOVApproachCoeffClosing;
var config float FOVApproachCoeffRun;
var config float FOVApproachCoeffWalk;
var float BatteryDuration;
var config float NrmBatteryDuration;
var config float HardBatteryDuration;
var config float CamcorderMinFOV;
var config float CamcorderMaxFOV;
var config float CamcorderNVMaxFOV;
var config float NVLightZoomedInInnerAngle;
var config float NVLightZoomedInOuterAngle;
var config float NVLightZoomedInRadius;
var config float NVLightZoomedInBrightness;
var config float DarkLightBrightnessDefault;
var config float DarkLightRadiusDefault;
var config float DarkLightBrightnessNoCamcorder;
var config float DarkLightRadiusNoCamcorder;
var config float DarkLightBrightnessBothHandsNeeded;
var config float DarkLightRadiusBothHandsNeeded;
var config float DarkLightBrightnessAttacked;
var config float DarkLightRadiusAttacked;
var config float DarkLightBrightnessParrying;
var config float DarkLightRadiusParrying;
var config float NVGlitchTimeThreshold;
var config float NVGlitchMaxDelayStart;
var config float NVGlitchMaxDelayEnd;
var config float NVGlitchMinDuration;
var config float NVGlitchMaxDuration;
var config float NVGlitchMaxLevel;
var config float HealthRegenRate;
var config float HealthRegenDelay;
var config float HobbleApproachRate;
var config float ElectricEffectPeriod;
var config float ElectricEffectBase;
var config int ElectricEffectMode;
var config float ElectricHurtSoundInterval;
var config float DeathScreenDuration;
var config int NumBloodyFootsteps;
var config float HeatDamageDist;
var config float HeatDamageInterval;
var config float HeatDamagePerSec;
var config float HeatMaxBlurDist;
var config float HeatMinBlurDist;
var config float HeatMinBlurAmount;
var config float HeatBlurApproachCoeffIn;
var config float HeatBlurApproachCoeffOut;
var config float MinCosAngleForPickup;
var config float PickupInteractRadius;
var config float JumpForwardFromLedgeWalkXYSpeed;
var config float JumpForwardFromLedgeWalkZSpeed;
var config float DropFromLedgeWalkXYSpeed;
var config float DropFromLedgeWalkZSpeed;
var config float LookBackCamRotOffset;
var config float LookBackCamBackOffset;
var config float LookBackCamSideOffset;
var config float LeanSpeedThreshold;
var config float WalkingLoudness;
var config float CrouchLoudness;
var config float RunningLoudness;
var config float WalkingWaterLoudness;
var config float CrouchWaterLoudness;
var config float HobblingWalkLoudness;
var config float HobblingRunLoudness;
var config float LandingBigLoudness;
var config float LandingSmallLoudness;
var config float LandingBigWaterLoudness;
var config float LandingSmallWaterLoudness;
var config float DoorOpenInstantLoudness;
var config float DoorOpenPartialLoudness;
var config float DoorCloseFastLoudness;
var config float DoorEnterLockerLoudness;
var config float DoorExitLockerLoudness;
var config float DoorRunThroughLoudness;
var config float MovingNoiseStartTime;
var config float MovingNoiseClearTime;
var const name CrouchNoise;
var const name WalkingNoise;
var const name RunningNoise;
var const name DoorMajorNoise;
var const float MovingNoiseRate;
var const name WaterMaterial;
var const name BloodMaterial;
var const ForceFeedbackWaveform BigLandingFFWaveform;
var const ForceFeedbackWaveform SmallLandingFFWaveform;
var const ForceFeedbackWaveform PickupFFWaveform;
var const ForceFeedbackWaveform DoorInteractionFFWaveform;
var const ForceFeedbackWaveform RunThroughDoorFFWaveform;
var const AkEvent FootStepSound_Run;
var const AkEvent SndCamStart;
var const AkEvent SndCamStop;
var const AkEvent SndCamOnNVOn;
var const AkEvent SndCamOnNVOff;
var const AkEvent SndCamOffNVOn;
var const AkEvent SndCamOffNVOff;
var const AkEvent SndReloadBatteries;
var const AkEvent SndPickupDocument;
var const AkEvent SndPickupBatteries;
var const AkEvent SndZoomIn;
var const AkEvent SndZoomOut;
var const AkEvent SndSoldierHit;
var const AkEvent SndDie;
var const AkEvent SndHit;
var const AkEvent SndHitElectrified;
var const AkEvent SndStartPeek;
var const AkEvent SndStopPeek;
var const AkEvent SndStartDamage;
var const AkEvent SndStopDamage;
var const AkEvent SndElectricHitStart;
var const AkEvent SndElectricHitStop;
var const AkEvent SndStartRun;
var const AkEvent SndStopRun;
var const AkEvent SndStartLookBack;
var const AkEvent SndStopLookBack;
var const AkEvent SndSmallLanding;
var const AkEvent SndBigLanding;
var const AkEvent SndDieMusicEvent;
var const AkEvent SndNewObjective;
var const AkEvent SndRecordingCompleted;
var const AkEvent SndLowBatteryStart;
var const AkEvent SndLowBatteryStop;
var const string StateHitIntensityGroup;
var const string StateHitIntensityLow;
var const string StateHitIntensityMed;
var const string StateHitIntensityHigh;
var const string RTPCHealth;
var const string RTPCZoom;
var const string RTPCBatteryIntensity;
var const name AnimNameJumpFromWalk;
var const name AnimNameJumpFromRun;
var const name AnimNameJumpOverFromWalk;
var const name AnimNameJumpOverFromRun;
var const name AnimNameJumpOverToGrabLedge;
var const name AnimNameClimbUpFromWalk;
var const name AnimNameClimbUpFromRun;
var const name AnimNameClimbUpToCrouch;
var const name AnimNameClimbUpWall150;
var const name AnimNameClimbUpWall200;
var const name AnimNameClimbOverWall200;
var const name AnimNameCrouch;
var const name AnimNameUncrouch;
var const name AnimNameLedgeHangLeftInside;
var const name AnimNameLedgeHangRightInside;
var const name AnimNameLedgeHangLeftOutside;
var const name AnimNameLedgeHangRightOutside;
var const name AnimNameClimbUpLedgeToCrouch;
var const name AnimNameClimbUpLedgeToStand;
var const name AnimNameClimbOverLedgeToFalling;
var const name AnimNameClimbOverLedgeToStand;
var const name AnimNameSlideOverFromRun;
var const name AnimNameGrabAndClimb;
var const name AnimNameGrabLedgeFromAir;
var const name AnimNameGrabLedgeFromWalkHigh;
var const name AnimNameGrabLedgeFromWalkLow;
var const name AnimNameLandingSmallStanding;
var const name AnimNameLandingSmallCrouched;
var const name AnimNameBigLandingStanding;
var const name AnimNameBigLandingCrouched;
var const name AnimNameEnterLedgeWalkInsideLeftPerp;
var const name AnimNameEnterLedgeWalkInsideLeftPrl;
var const name AnimNameEnterLedgeWalkInsideRightPerp;
var const name AnimNameEnterLedgeWalkInsideRightPrl;
var const name AnimNameEnterLedgeWalkOutsideLeftPerp;
var const name AnimNameEnterLedgeWalkOutsideLeftPrl;
var const name AnimNameEnterLedgeWalkOutsideRightPerp;
var const name AnimNameEnterLedgeWalkOutsideRightPrl;
var const name AnimNameLedgeWalkTransitionLeftInside;
var const name AnimNameLedgeWalkTransitionLeftOutside;
var const name AnimNameLedgeWalkTransitionRightInside;
var const name AnimNameLedgeWalkTransitionRightOutside;
var const name AnimNameExitLedgeWalkRightInside;
var const name AnimNameExitLedgeWalkLeftInside;
var const name AnimNameExitLedgeWalkRightOutside;
var const name AnimNameExitLedgeWalkLeftOutside;
var const name AnimNameJumpFromLedgeWalk;
var const name AnimNameStepOffFromLedgeWalk;
var const name AnimNameEnterSqueezeLeft;
var const name AnimNameEnterSqueezeRight;
var const name AnimNameExitSqueezeLeft;
var const name AnimNameExitSqueezeRight;
var const name AnimNameAutomaticSqueeze;
var const name AnimNameEnterLadderGroundStraight;
var const name AnimNameEnterLadderGround45Left;
var const name AnimNameEnterLadderGround45Right;
var const name AnimNameExitLadderOnTopLH;
var const name AnimNameExitLadderOnTopRH;
var const name AnimNamePickupObject_h40v70;
var const name AnimNamePickupObject_h40v140;
var const name AnimNamePickupObject_h85v70;
var const name AnimNamePickupObject_h85v140;
var const name AnimNamePickupObject_h62v105;
var const name AnimNamePickupObjectCrouched_h30vm10;
var const name AnimNamePickupObjectCrouched_h60vm10;
var const name AnimNamePickupObjectCrouched_h45v35;
var const name AnimNamePickupObjectCrouched_h30v60;
var const name AnimNamePickupObjectCrouched_h60v60;
var const name AnimNamePickupDoc_h40v70;
var const name AnimNamePickupDoc_h40v140;
var const name AnimNamePickupDoc_h85v70;
var const name AnimNamePickupDoc_h85v140;
var const name AnimNamePickupDoc_h62v105;
var const name AnimNamePickupDocCrouched_h30vm10;
var const name AnimNamePickupDocCrouched_h60vm10;
var const name AnimNamePickupDocCrouched_h45v35;
var const name AnimNamePickupDocCrouched_h30v60;
var const name AnimNamePickupDocCrouched_h60v60;
var const name AnimNamePutdownObject;
var const name AnimNameCloseDoorLeftFront;
var const name AnimNameCloseDoorLeftSide;
var const name AnimNameCloseDoorLeftBack;
var const name AnimNameCloseDoorLeftInside;
var const name AnimNameCloseDoorRightFront;
var const name AnimNameCloseDoorRightSide;
var const name AnimNameCloseDoorRightBack;
var const name AnimNameCloseDoorRightInside;
var const name AnimNameCloseDoorLeftFrontSlow;
var const name AnimNameCloseDoorLeftSideSlow;
var const name AnimNameCloseDoorLeftBackSlow;
var const name AnimNameCloseDoorLeftInsideSlow;
var const name AnimNameCloseDoorRightFrontSlow;
var const name AnimNameCloseDoorRightSideSlow;
var const name AnimNameCloseDoorRightBackSlow;
var const name AnimNameCloseDoorRightInsideSlow;
var const name AnimNameDoorOpenPullLeft;
var const name AnimNameDoorOpenPullRight;
var const name AnimNameDoorOpenPushLeft;
var const name AnimNameDoorOpenPushRight;
var const name AnimNameDoorRunThroughLeft;
var const name AnimNameDoorRunThroughRight;
var const name AnimNameDoorOpenInsidePushLeft;
var const name AnimNameDoorOpenInsidePushRight;
var const name AnimNameDoorAccessLeft;
var const name AnimNameDoorAccessRight;
var const name AnimNameDoorAccessLeftPull15;
var const name AnimNameDoorAccessRightPull15;
var const name AnimNameDoorAccessLeftPush15;
var const name AnimNameDoorAccessRightPush15;
var const name AnimNameDoorLockedLeft;
var const name AnimNameDoorLockedRight;
var const name AnimNameLockerOpenStraight;
var const name AnimNameLockerOpen45Left;
var const name AnimNameLockerOpen45Right;
var const name AnimNameHideInLocker;
var const name AnimNameGrabFromSqueezeLeftFacing;
var const name AnimNameGrabFromSqueezeLeftBack;
var const name AnimNameGrabFromSqueezeRightFacing;
var const name AnimNameGrabFromSqueezeRightBack;
var const name AnimNameGrabFromSqueezePhase1Right0;
var const name AnimNameGrabFromSqueezePhase1Right90;
var const name AnimNameGrabFromSqueezePhase1Right180;
var const name AnimNameGrabFromSqueezePhase1Left0;
var const name AnimNameGrabFromSqueezePhase1Left90;
var const name AnimNameGrabFromSqueezePhase1Left180;
var const name AnimNameEnterBedLeft;
var const name AnimNameEnterBedRight;
var const name AnimNameEnterBedLeftFromStand;
var const name AnimNameEnterBedRightFromStand;
var const name AnimNameExitBedLeft;
var const name AnimNameExitBedRight;
var const name AnimNameExitBedLeftToCrouch;
var const name AnimNameExitBedRightToCrouch;
var const name AnimNameEnterPushObjectLeft;
var const name AnimNameEnterPushObjectRight;
var const name AnimNameExitPushObjectLeft;
var const name AnimNameExitPushObjectRight;
var const name AnimNameRaiseCamcorder;
var const name AnimNameLowerCamcorder;
var const name AnimNameRaiseCamcorderBed;
var const name AnimNameLowerCamcorderBed;
var const name AnimNameRaiseCamcorderCrouched;
var const name AnimNameLowerCamcorderCrouched;
var const name AnimNameReloadBatteries;
var const name AnimNameReloadBatteriesInactive;
var const name AnimNameReloadBatteriesCrouched;
var const name AnimNameReloadBatteriesCrouchedInactive;
var const name AnimNameReloadBatteriesBed;
var const name AnimNameReloadBatteriesBedInactive;
var const name AnimNameReloadBatteriesSqueeze;
var const name AnimNameReloadBatteriesSqueezeInactive;
var const name AnimNameGrabNormal;
var const name AnimNameGrabNormalLeft90;
var const name AnimNameGrabNormalLeft180;
var const name AnimNameGrabNormalRight90;
var const name AnimNameGrabNormalRight180;
var const name AnimNameGrabCrouched;
var const name AnimNameGrabCrouchedLeft90;
var const name AnimNameGrabCrouchedLeft180;
var const name AnimNameGrabCrouchedRight90;
var const name AnimNameGrabCrouchedRight180;
var const name AnimNameGrabUnder;
var const name AnimNameGrabUnderCCW;
var const name AnimNameGrabUnderLeft90;
var const name AnimNameGrabUnderLeft180;
var const name AnimNameGrabUnderRight90;
var const name AnimNameGrabUnderRight180;
var const name AnimNameGrabFromBedLeft;
var const name AnimNameGrabFromBedRight;
var const name AnimNameGrabFromLocker;
var const name AnimNameThrown;
var const name AnimNameThrownLeft90;
var const name AnimNameThrownLeft180;
var const name AnimNameThrownRight90;
var const name AnimNameThrownRight180;
var const name AnimNameHitReactionFwd;
var const name AnimNameHitReactionBwd;
var const name AnimNameHitReactionLeft;
var const name AnimNameHitReactionRight;
var const name AnimNameHitReactionCrouchedFwd;
var const name AnimNameHitReactionCrouchedBwd;
var const name AnimNameHitReactionCrouchedLeft;
var const name AnimNameHitReactionCrouchedRight;
var const name AnimNameWallContactLeftHard;
var const name AnimNameWallContactLeftSoft;
var const name AnimNameWallContactRightHard;
var const name AnimNameWallContactRightSoft;
var const name AnimNameEnterCornerPeekLeftHard;
var const name AnimNameEnterCornerPeekLeftSoft;
var const name AnimNameEnterCornerPeekRightHard;
var const name AnimNameEnterCornerPeekRightSoft;
var const name AnimNameExitCornerPeekLeftHard;
var const name AnimNameExitCornerPeekLeftSoft;
var const name AnimNameExitCornerPeekRightHard;
var const name AnimNameExitCornerPeekRightSoft;
var const name AnimNameExitCornerPeekForwardLeftHard;
var const name AnimNameExitCornerPeekForwardLeftSoft;
var const name AnimNameExitCornerPeekForwardRightHard;
var const name AnimNameExitCornerPeekForwardRightSoft;
var const name AnimNameCornerTransitionFromLeft;
var const name AnimNameCornerTransitionFromRight;
var const name AnimNameGenericGrabFromBedLeft;
var const name AnimNameGenericGrabFromBedRight;
var const name AnimNameGenericGrabFromLocker;
var const name AnimNameGenericGrabUnder;
var const name AnimNameGenericGrabUnderLeft90;
var const name AnimNameGenericGrabUnderLeft180;
var const name AnimNameGenericGrabUnderRight90;
var const name AnimNameGenericGrabUnderRight180;
var const name AnimNamePushawayLeft;
var const name AnimNamePushawayRight;
var const name AnimNameGenericDeath;
var const name AnimNameFatalityBackstabBack;
var const name AnimNameFatalityBackstabLeft;
var const name AnimNameFatalityBackstabRight;
var const name AnimNameFatalityChokeFront;
var const name AnimNameFatalityChokeLeft;
var const name AnimNameFatalityChokeRight;
var const name AnimNameFatalityClubBack;
var const name AnimNameFatalityClubFront;
var const name AnimNameFatalityClubLeft;
var const name AnimNameFatalityClubRight;
var const name AnimNameFatalityStabChopFront;
var const name AnimNameFatalityStabChopLeft;
var const name AnimNameFatalityStabChopRight;
var const name AnimNameFatalityXplodeBack;
var const name AnimNameFatalityXplodeFront;
var const name AnimNameFatalityXplodeLeft;
var const name AnimNameFatalityXplodeRight;
var const name AnimNameFatalityLocker;
var const name AnimNameFatalitySoldier;
var const name AnimNameFatalityGroom;
var const float ObstacleMinZWalking;
var const float ObstacleMaxZWalking;
var const float ObstacleMinZFalling;
var const float ObstacleMaxZFalling;
var const float MinCosAngleToObstacle;
var const float MaxLedgeCosAngle;
var const float MinWidthForClimbWalking;
var const float MinWidthForClimbRunning;
var const float MinWidthForClimbUpWall;
var const float MinWidthForSlide;
var const float MaxWidthForSlide;
var const float MinHeightForSlide;
var const float MaxHeightForSlide;
var const float StepUpAndLandInteractDist;
var const float JumpOverInteractDistWalking;
var const float JumpOverInteractDistRunning;
var const float JumpOverInteractDistFalling;
var const float JumpOverMinObstacleZ;
var const float JumpOverExpectedDistWalking;
var const float JumpOverExpectedHeightWalking;
var const float JumpOverExpectedDistRunning;
var const float JumpOverExpectedHeightRunning;
var const float JumpOverAndGrabLedgeInteractDistWalking;
var const float JumpOverAndGrabLedgeInteractDistRunning;
var const float JumpOverAndGrabLedgeInteractDistFalling;
var const float JumpOverAndGrabLedgeExpectedDist;
var const float JumpOverAndGrabLedgeExpectedHeightFromLedge;
var const float SlideOverInteractDistMin;
var const float SlideOverInteractDistMax;
var const float SlideOverExpectedDist;
var const float SlideOverExpectedHeight;
var const float ClimbUpInteractDistWalking;
var const float ClimbUpInteractDistRunning;
var const float ClimbUpInteractDistFalling;
var const float ClimbUpWallInteractHeightMin;
var const float ClimbUpExpectedDistWalking;
var const float ClimbUpExpectedHeightWalking;
var const float ClimbUpExpectedDistRunning;
var const float ClimbUpExpectedHeightRunning;
var const float ClimbUpWallExpectedDist;
var const float ClimbUpWallExpectedHeightMin;
var const float ClimbUpWallExpectedHeightMax;
var const float ClimbOverWallExpectedDist;
var const float ClimbOverWallExpectedHeight;
var const float ClimbUpToCrouchExpectedDist;
var const float ClimbUpToCrouchExpectedHeight;
var const float ClimbUpToCrouchMinHeight;
var const float GrabLedgeInteractDistWalking;
var const float GrabLedgeInteractDistRunning;
var const float GrabLedgeMinHeightOnGround;
var const float GrabLedgeMaxHeightOnGround;
var const float GrabLedgeMinFloorClearance;
var const float GrabLedgeFromJumpOverMinFloorClearance;
var const float GrabLedgeMinHeightInAir;
var const float GrabLedgeMaxHeightInAir;
var const float GrabLedgeInteractDistGoingDown;
var const float GrabLedgeMinHeightInAirGoingDown;
var const float GrabLedgeMaxHeightInAirGoingDown;
var const float GrabLedgeFromGroundExpectedHeight;
var const float GrabLedgeFromAirExpectedHeight;
var const float GrabAndClimbInteractDist;
var const float GrabAndClimbExpectedDistFwd;
var const float GrabAndClimbExpectedDistHeight;
var const float GrabAndClimbMinHeight;
var const float GrabAndClimbMaxHeight;
var const float LedgeHangDistToWall;
var const float LedgeHangHeightToLedge;
var const float LedgeHangTransitionInteractDist;
var const float LedgeHangTransitionInsideExpectedDist;
var const float LedgeHangTransitionOutsideExpectedDist;
var const float LedgeHangClimbOverMaxLedgeWidth;
var const float LedgeHangClimbOverMinHeightClearance;
var const float LedgeHangClimbOverFullHeightClearance;
var const float LedgeHangClimbUpMinFwdClearance;
var const float LedgeWalkTransitionInteractDistInside;
var const float LedgeWalkTransitionInteractDistOutside;
var const float LedgeWalkTransitionInteractDistExit;
var const float LedgeWalkEnterExpectedInsidePerpSideDist;
var const float LedgeWalkEnterExpectedOutsidePerpSideDist;
var const float LedgeWalkEnterExpectedInsidePrlSideDist;
var const float LedgeWalkEnterExpectedOutsidePrlSideDist;
var const float LedgeWalkEnterExpectedInsidePerpFwdDist;
var const float LedgeWalkEnterExpectedOutsidePerpFwdDist;
var const float LedgeWalkEnterExpectedInsidePrlFwdDist;
var const float LedgeWalkEnterExpectedOutsidePrlFwdDist;
var const float LedgeWalkTransitionExpectedDistInside;
var const float LedgeWalkTransitionExpectedDistOutside;
var const float LedgeWalkDistFromEdge;
var const float LedgeWalkMaxWallDist;
var const float LedgeWalkMinDrop;
var const float SqueezeInteractDist;
var const float SqueezeEnterExpectedDistFwd;
var const float SqueezeExitExpectedDistFwd;
var const float SqueezeDistFromCenter;
var const float EnterLockerInteractDistance;
var const float LadderEnterFromGroundInteractDist;
var const float LadderEnterFromAboveInteractDist;
var const float LadderGrabDist;
var const float LadderEnterFromGroundDeltaZ;
var const float LadderBarSpacing;
var const float LadderRootHeightOffsetFromBar;
var const float LadderEnterFromAboveExpectedDist;
var const float LadderDistFwd;
var const float LadderExitOnTopInteractDist;
var const float LadderExitOnGroundInteractDist;
var const float LadderMaxHeightForDrop;
var const float PickupObjectExpectedDist;
var const float PickupObjectInteractDistMinHorz;
var const float PickupObjectInteractDistMaxHorz;
var const float PickupObjectInteractDistMinVertStanding;
var const float PickupObjectInteractDistMaxVertStanding;
var const float PickupObjectInteractDistMinVertCrouched;
var const float PickupObjectInteractDistMaxVertCrouched;
var const float DoorOpenInteractionDist;
var const float DoorOpenExpectedFwdDist;
var const float DoorOpenExpectedSideDist;
var const float DoorOpenInsideExpectedDistFwd;
var const float DoorRunThroughInteractDist;
var const float DoorRunThroughExpectedDist;
var const float DoorInteractiveOpenMaxAngle;
var const float DoorMaxAngleForInteractiveOpen;
var const float DoorCloseInteractionDist;
var const float DoorCloseExpectedDistFwd;
var const float LockerOpenStraightExpectedDistSide;
var const float LockerOpenLeftExpectedDistSide;
var const float LockerOpenRightExpectedDistSide;
var const float LockerOpenExpectedDistFwd;
var const float LockerEnterExpectedDistSide;
var const float LockerEnterExpectedDistFwd;
var const float GrabFromSqueezeMaxDistance;
var const float GrabFromSqueezeExpectedDistance;
var const float BedInteractDistance;
var const float BedEnterExpectedFwdDist;
var const float BedEnterExpectedSideDist;
var const float PushableInteractDist;
var const float PushableInteractMinLookCosAngle;
var const float PushableExpectedDistFromEdge;
var const float PushableExpectedSideOffset;
var const float PushFromLedgeAnimatedExpectedDist;
var const float PushFromLedgeAnimatedInteractDist;
var const float PushFromLedgeAnimatedMinHeight;
var const float PushFromLedgeProceduralInteractDist;
var const float PeekingEnterInteractDistFromWall;
var const float PeekingEnterInteractDistFromEdgeMin;
var const float PeekingEnterInteractDistFromEdgeMax;
var const float PeekingEnterExpectedDistFromWall;
var const float PeekingEnterExpectedDistFromEdgeLeft;
var const float PeekingEnterExpectedDistFromEdgeRight;
var const float ImpactVelThresholdForBigLanding;
var const float ImpactVelThresholdForSmallLanding;
var const float ImpactVelThresholdForSpeedPenalty;
var const float MinEyeDistToWall;
var const float ForwardJumpSpeedThreshold;
var const float MaxGrabLedgeAdjustment;
var const float MaxSpeedPenaltyPctForInjuries;
var const Vector DefaultLeftHandJointTargetRotation;
var const Vector CornerPeekJointTargetPosLeft;
var const Vector CornerPeekJointTargetPosRight;

// Export UOLHero::execGetPawnViewLocation(FFrame&, void* const)
native simulated function Vector GetPawnViewLocation();

// Export UOLHero::execGetViewRotation(FFrame&, void* const)
native simulated event Rotator GetViewRotation();

// Export UOLHero::execWalk(FFrame&, void* const)
native function Walk();

// Export UOLHero::execTryRun(FFrame&, void* const)
native function bool TryRun();

// Export UOLHero::execIsRunning(FFrame&, void* const)
native function bool IsRunning();

// Export UOLHero::execResetAfterTeleport(FFrame&, void* const)
native function ResetAfterTeleport();

// Export UOLHero::execNativePostBeginPlay(FFrame&, void* const)
native function NativePostBeginPlay();

// Export UOLHero::execGetCamera(FFrame&, void* const)
native function GetCamera(out Vector out_CamLoc, out Rotator out_CamRot, out float out_FOV);

// Export UOLHero::execNativeDisplayDebug(FFrame&, void* const)
native function NativeDisplayDebug(Canvas Canvas, out float out_YL, out float out_YPos);

// Export UOLHero::execNativeTakeDamage(FFrame&, void* const)
native function NativeTakeDamage(int Damage, Controller InstigatedBy, Vector HitLocation, Class<DamageType> DamageType);

// Export UOLHero::execNativeTakeFallingDamage(FFrame&, void* const)
native function NativeTakeFallingDamage();

// Export UOLHero::execTakeElectricDamage(FFrame&, void* const)
native function TakeElectricDamage(int Damage, float Knockback, Vector HitNormal, AkEvent ElectricSoundEvent);

// Export UOLHero::execActivateWaterFootstepParticles(FFrame&, void* const)
native function ActivateWaterFootstepParticles(bool bRightFoot);

// Export UOLHero::execOnPossess(FFrame&, void* const)
native function OnPossess();

// Export UOLHero::execStartSpecialMove(FFrame&, void* const)
native function StartSpecialMove(OLPawn.ESpecialMoveType moveType, optional Vector targetPosition, optional Vector TargetDirection, optional OLPawn.EAdjustPositionTargetType TargetType);

// Export UOLHero::execEnterCinematicMode(FFrame&, void* const)
native function EnterCinematicMode(SeqAct_ToggleCinematicMode seqAction);

// Export UOLHero::execExitCinematicMode(FFrame&, void* const)
native function ExitCinematicMode(SeqAct_ToggleCinematicMode seqAction);

// Export UOLHero::execHeroControlActivated(FFrame&, void* const)
native function bool HeroControlActivated(OLSeqAct_HeroControl heroControlAction);

// Export UOLHero::execTryGrabFromSqueeze(FFrame&, void* const)
native function bool TryGrabFromSqueeze(OLEnemyPawn attacker);

// Export UOLHero::execCanGrabFromSqueeze(FFrame&, void* const)
native function bool CanGrabFromSqueeze();

// Export UOLHero::execTryGrabFromLocker(FFrame&, void* const)
native function bool TryGrabFromLocker(OLEnemyPawn attacker);

// Export UOLHero::execTryExitLocker(FFrame&, void* const)
native function bool TryExitLocker();

// Export UOLHero::execTryExitBed(FFrame&, void* const)
native function bool TryExitBed(Vector playerIntentDirection);

// Export UOLHero::execTryGrabFromBed(FFrame&, void* const)
native function bool TryGrabFromBed(OLEnemyPawn attacker);

// Export UOLHero::execTryGrabNormal(FFrame&, void* const)
native function bool TryGrabNormal(OLEnemyPawn attacker, Vector StartLocation, Vector AttackStartLocation);

// Export UOLHero::execTryThrowPlayer(FFrame&, void* const)
native function bool TryThrowPlayer(OLEnemyPawn attacker, float ThrowRotation);

// Export UOLHero::execTryGrabFromUnder(FFrame&, void* const)
native function bool TryGrabFromUnder(OLEnemyPawn attacker, Vector StartLocation, Vector AttackStartLocation);

// Export UOLHero::execTryDecapitate(FFrame&, void* const)
native function bool TryDecapitate(OLEnemyPawn attacker);

// Export UOLHero::execTryKillHero(FFrame&, void* const)
native function bool TryKillHero(OLEnemyPawn attacker, Vector enemyStartLocation, Vector Direction);

// Export UOLHero::execTryKillInLocker(FFrame&, void* const)
native function bool TryKillInLocker(OLEnemyPawn attacker);

// Export UOLHero::execReactToHit(FFrame&, void* const)
native function ReactToHit(float hitStrength, Vector hitDirection, optional bool bForceFullPower);

// Export UOLHero::execPickupNotify(FFrame&, void* const)
native function PickupNotify();

// Export UOLHero::execDoorAnimNotify(FFrame&, void* const)
native function DoorAnimNotify();

// Export UOLHero::execCamcorderAvailableNotify(FFrame&, void* const)
native function CamcorderAvailableNotify();

// Export UOLHero::execCamcorderRaisedNotify(FFrame&, void* const)
native function CamcorderRaisedNotify();

// Export UOLHero::execCamcorderLoweredNotify(FFrame&, void* const)
native function CamcorderLoweredNotify();

// Export UOLHero::execBatteriesReloadedNotify(FFrame&, void* const)
native function BatteriesReloadedNotify();

// Export UOLHero::execOverrideCameraSettingsNotify(FFrame&, void* const)
native function OverrideCameraSettingsNotify(OLAnimNotify_OverrideCameraParams camParamsNotify);

// Export UOLHero::execDieNotify(FFrame&, void* const)
native function DieNotify();

// Export UOLHero::execDecapitatedNotify(FFrame&, void* const)
native function DecapitatedNotify();

// Export UOLHero::execBloodOnScreenNotify(FFrame&, void* const)
native function BloodOnScreenNotify();

// Export UOLHero::execResetNeckOffsetNotify(FFrame&, void* const)
native function ResetNeckOffsetNotify();

// Export UOLHero::execSetCamcorderVisibleNotify(FFrame&, void* const)
native function SetCamcorderVisibleNotify();

// Export UOLHero::execAttachCameraEffect(FFrame&, void* const)
native function AttachCameraEffect(ParticleSystem ParticleEffectTemplate, float Duration, float PlaneDist);

// Export UOLHero::execIsInLocker(FFrame&, void* const)
native function bool IsInLocker();

// Export UOLHero::execIsBarefeet(FFrame&, void* const)
native function bool IsBarefeet();

// Export UOLHero::execCanBeAttacked(FFrame&, void* const)
native function bool CanBeAttacked();

// Export UOLHero::execCanBeFatalitized(FFrame&, void* const)
native function bool CanBeFatalitized();

// Export UOLHero::execCanBeGrabbedUnder(FFrame&, void* const)
native function bool CanBeGrabbedUnder();

// Export UOLHero::execQuickHeroTest(FFrame&, void* const)
native exec function QuickHeroTest();

// Export UOLHero::execGetFutureDestination(FFrame&, void* const)
native function Vector GetFutureDestination(OLPawn Agent);

// Export UOLHero::execGetGrabUnderDestination(FFrame&, void* const)
native function Vector GetGrabUnderDestination(OLEnemyPawn Enemy);

// Export UOLHero::execRemoveEnemyFromAIPositionPawns(FFrame&, void* const)
native function RemoveEnemyFromAIPositionPawns(OLEnemyPawn EnemyPawn);

function PossessedBy(Controller C, bool bVehicleTransition)
{
    super(Pawn).PossessedBy(C, bVehicleTransition);
    OLPC = OLPlayerController(C);
    UpdateDifficultyBasedValues();
    OLPC.UpdateDifficultyBasedValues();
    OnPossess();
    //return;    
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    // End:0x80E
    if(__NFUN_114__(SkelComp, Mesh))
    {
        UpperBodyBlendNode = OLAnimCustomBlend(Mesh.FindAnimNode('UpperBodyBlend'));
        RightArmAnimSlot = AnimNodeSlot(Mesh.FindAnimNode('RightArmAnimSlot'));
        LeftArmAnimSlot = AnimNodeSlot(Mesh.FindAnimNode('LeftArmAnimSlot'));
        SqueezeAnimNode = OLAnimConstrainedMovement(Mesh.FindAnimNode('Squeeze'));
        LedgeWalkAnimNode = OLAnimConstrainedMovement(Mesh.FindAnimNode('LedgeWalk'));
        LedgeHangAnimNode = OLAnimConstrainedMovement(Mesh.FindAnimNode('LedgeHang'));
        LadderAnimNode = OLAnimMultiCycleConstrainedMovement(Mesh.FindAnimNode('Ladder'));
        DoorAnimNode = OLAnimDoorInteraction(Mesh.FindAnimNode('door'));
        PeekingAnimNode = OLAnimPeeking(Mesh.FindAnimNode('Peeking'));
        LocomotionAnimNode = OLAnimBlendByLocomotionMode(Mesh.FindAnimNode('LocomotionMode'));
        BlendByPostureWalkingAnimNode = OLAnimBlendByPosture(Mesh.FindAnimNode('BlendByPostureWalking'));
        BlendByPostureFallingAnimNode = OLAnimBlendByPosture(Mesh.FindAnimNode('BlendByPostureFalling'));
        LeftArmWallContactFilterNode = AnimNodeBlendPerBone(Mesh.FindAnimNode('LeftArmWallContact'));
        LeftArmWallContactAnimSequence = AnimNodeSequence(Mesh.FindAnimNode('WallContactSlot'));
        BedAnimNode = AnimNodeSequence(Mesh.FindAnimNode('Bed'));
        RightHandIK = SkelControlLimb(Mesh.FindSkelControl('RightHandIK'));
        LeftHandIK = SkelControlLimb(Mesh.FindSkelControl('LeftHandIK'));
        LeftFootPlacementNode = AnimNodeBlendPerBone(Mesh.FindAnimNode('LeftFootPlacement'));
        RightFootPlacementNode = AnimNodeBlendPerBone(Mesh.FindAnimNode('RightFootPlacement'));
        HiddenRightArmControl = SkelControlSingleBone(Mesh.FindSkelControl('HiddenRightArm'));
        HiddenLeftArmControl = SkelControlSingleBone(Mesh.FindSkelControl('HiddenLeftArm'));
        StruggleAnimNode = OLAnimStruggleCycle(Mesh.FindAnimNode('Struggle'));
        CrouchTurnOnSpotAnimNode = OLAnimCrouchedTurnOnSpot(Mesh.FindAnimNode('CrouchedTurnOnSpot'));
        ParryingAnimNode = OLAnimParrying(Mesh.FindAnimNode('Parrying'));
        LeanStandingAnimNode = OLAnimBlendByLeaning(Mesh.FindAnimNode('LeanStanding'));
        LeanCrouchedAnimNode = OLAnimBlendByLeaning(Mesh.FindAnimNode('LeanCrouched'));
        LeftForeTwistControl = Mesh.FindSkelControl('LeftForeTwist');
        LeftForeTwist1Control = Mesh.FindSkelControl('LeftForeTwist1');
        LeftUpArmTwistControl = Mesh.FindSkelControl('LeftUpArmTwist');
        LeftHandIK.ControlStrength = 0.0000000;
        LeftForeTwistControl.ControlStrength = 0.0000000;
        LeftForeTwist1Control.ControlStrength = 0.0000000;
        LeftUpArmTwistControl.ControlStrength = 0.0000000;
        RightForeTwistControl = Mesh.FindSkelControl('RightForeTwist');
        RightUpArmTwistControl = Mesh.FindSkelControl('RightUpArmTwist');
        RightHandIK.ControlStrength = 0.0000000;
        RightForeTwistControl.ControlStrength = 0.0000000;
        RightUpArmTwistControl.ControlStrength = 0.0000000;        
    }
    else
    {
        // End:0xF48
        if(__NFUN_114__(SkelComp, ShadowProxy))
        {
            ShadowProxyFullBodyAnimSlot = OLAnimNodeSlot(ShadowProxy.FindAnimNode('FullBodySlot'));
            ShadowProxyCustomBlendNode = OLAnimCustomBlend(ShadowProxy.FindAnimNode('CustomBlend'));
            ShadowProxyUpperBodyBlendNode = OLAnimCustomBlend(ShadowProxy.FindAnimNode('UpperBodyBlend'));
            ShadowProxyRightArmAnimSlot = AnimNodeSlot(ShadowProxy.FindAnimNode('RightArmAnimSlot'));
            ShadowProxyLeftArmAnimSlot = AnimNodeSlot(ShadowProxy.FindAnimNode('LeftArmAnimSlot'));
            ShadowProxySqueezeAnimNode = OLAnimConstrainedMovement(ShadowProxy.FindAnimNode('Squeeze'));
            ShadowProxyLedgeWalkAnimNode = OLAnimConstrainedMovement(ShadowProxy.FindAnimNode('LedgeWalk'));
            ShadowProxyLedgeHangAnimNode = OLAnimConstrainedMovement(ShadowProxy.FindAnimNode('LedgeHang'));
            ShadowProxyLadderAnimNode = OLAnimMultiCycleConstrainedMovement(ShadowProxy.FindAnimNode('Ladder'));
            ShadowProxyDoorAnimNode = OLAnimDoorInteraction(ShadowProxy.FindAnimNode('door'));
            ShadowProxyPeekingAnimNode = OLAnimPeeking(ShadowProxy.FindAnimNode('Peeking'));
            ShadowProxyLeftArmWallContactFilterNode = AnimNodeBlendPerBone(ShadowProxy.FindAnimNode('LeftArmWallContact'));
            ShadowProxyLeftArmWallContactAnimSequence = AnimNodeSequence(ShadowProxy.FindAnimNode('WallContactSlot'));
            ShadowProxyBedAnimNode = AnimNodeSequence(ShadowProxy.FindAnimNode('Bed'));
            ShadowProxyLeftHandIK = SkelControlLimb(ShadowProxy.FindSkelControl('LeftHandIK'));
            ShadowProxyLeftFootPlacementNode = AnimNodeBlendPerBone(ShadowProxy.FindAnimNode('LeftFootPlacement'));
            ShadowProxyRightFootPlacementNode = AnimNodeBlendPerBone(ShadowProxy.FindAnimNode('RightFootPlacement'));
            ShadowProxyStruggleAnimNode = OLAnimStruggleCycle(ShadowProxy.FindAnimNode('Struggle'));
            ShadowProxyCrouchTurnOnSpotAnimNode = OLAnimCrouchedTurnOnSpot(ShadowProxy.FindAnimNode('CrouchedTurnOnSpot'));
            ShadowProxyParryingAnimNode = OLAnimParrying(ShadowProxy.FindAnimNode('Parrying'));
            ShadowProxyLeftForeTwistControl = ShadowProxy.FindSkelControl('LeftForeTwist');
            ShadowProxyLeftForeTwist1Control = ShadowProxy.FindSkelControl('LeftForeTwist1');
            ShadowProxyLeftUpArmTwistControl = ShadowProxy.FindSkelControl('LeftUpArmTwist');
            ShadowProxyRightHandIK = SkelControlLimb(ShadowProxy.FindSkelControl('ShadowProxyRightHandIK'));
            ShadowProxyRightForeTwistControl = ShadowProxy.FindSkelControl('ShadowProxyRightForeTwist');
            ShadowProxyRightUpArmTwistControl = ShadowProxy.FindSkelControl('ShadowProxyRightUpArmTwist');
            ShadowProxyRightClavicleFixup = ShadowProxy.FindSkelControl('ShadowProxyRightClavicleFixup');
            ShadowProxyLeftHandIK.ControlStrength = 0.0000000;
            ShadowProxyLeftForeTwistControl.ControlStrength = 0.0000000;
            ShadowProxyLeftForeTwist1Control.ControlStrength = 0.0000000;
            ShadowProxyLeftUpArmTwistControl.ControlStrength = 0.0000000;
            ShadowProxyRightHandIK.ControlStrength = 0.0000000;
            ShadowProxyRightForeTwistControl.ControlStrength = 0.0000000;
            ShadowProxyRightUpArmTwistControl.ControlStrength = 0.0000000;
            ShadowProxyRightClavicleFixup.ControlStrength = 0.0000000;
        }
    }
    super.PostInitAnimTree(SkelComp);
    //return;    
}

simulated function DisplayDebug(HUD HUD, out float out_YL, out float out_YPos)
{
    // End:0x39
    if(OLPC.HUD.ShowingFullScreenOverlay())
    {
        return;
    }
    super.DisplayDebug(HUD, out_YL, out_YPos);
    NativeDisplayDebug(HUD.Canvas, out_YL, out_YPos);
    //return;    
}

event TakeDamage(int Damage, Controller InstigatedBy, Vector HitLocation, Vector Momentum, Class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
    NativeTakeDamage(Damage, InstigatedBy, HitLocation, DamageType);
    //return;    
}

event bool HealDamage(int Amount, Controller Healer, Class<DamageType> DamageType)
{
    // End:0x5D
    if(__NFUN_130__(__NFUN_151__(Health, 0), __NFUN_150__(Health, 100)))
    {
        Health = __NFUN_249__(100, __NFUN_146__(Health, Amount));
        PreciseHealth = float(Health);
        return true;        
    }
    else
    {
        return false;
    }
    //return ReturnValue;    
}

function TakeFallingDamage()
{
    NativeTakeFallingDamage();
    //return;    
}

// Export UOLHero::execNativePlayLanded(FFrame&, void* const)
native function NativePlayLanded(float ImpactVel);

function PlayLanded(float ImpactVel)
{
    super.PlayLanded(ImpactVel);
    NativePlayLanded(ImpactVel);
    //return;    
}

// Export UOLHero::execOnEnterDeepWater(FFrame&, void* const)
native function OnEnterDeepWater(PhysicsVolume NewVolume);

event PhysicsVolumeChange(PhysicsVolume NewVolume)
{
    // End:0x46
    if(__NFUN_130__(__NFUN_119__(NewVolume, none), NewVolume.bWaistDeepWater))
    {
        OnEnterDeepWater(NewVolume);
    }
    //return;    
}

simulated event BecomeViewTarget(PlayerController PC)
{
    super(Pawn).BecomeViewTarget(PC);
    // End:0x61
    if(__NFUN_119__(LocalPlayer(PC.Player), none))
    {
        PawnAmbientSound.bAllowSpatialization = false;
    }
    //return;    
}

simulated event EndViewTarget(PlayerController PC)
{
    PawnAmbientSound.bAllowSpatialization = true;
    //return;    
}

simulated function SetMeshVisibility(bool bVisible)
{
    // End:0x3A
    if(__NFUN_119__(Mesh, none))
    {
        Mesh.SetOwnerNoSee(__NFUN_129__(bVisible));
    }
    //return;    
}

// Export UOLHero::execGetFootstepDecalTransform(FFrame&, void* const)
native function GetFootstepDecalTransform(bool bLeftFoot, out Vector DecalLocation, out Rotator DecalRotation);

function SpawnBloodFootstepDecal(bool bLeftFoot, float Alpha)
{
    local MaterialInstanceConstant ParentMI, DecalMI;
    local Vector DecalLocation;
    local Rotator DecalRotation;

    GetFootstepDecalTransform(bLeftFoot, DecalLocation, DecalRotation);
    // End:0xAC
    if(IsBarefeet())
    {
        // End:0x76
        if(bLeftFoot)
        {
            // End:0x60
            if(__NFUN_154__(__NFUN_167__(2), 0))
            {
                ParentMI = FootstepBarefeetDecalMatL1;                
            }
            else
            {
                ParentMI = FootstepBarefeetDecalMatL2;
            }            
        }
        else
        {
            // End:0x96
            if(__NFUN_154__(__NFUN_167__(2), 0))
            {
                ParentMI = FootstepBarefeetDecalMatR1;                
            }
            else
            {
                ParentMI = FootstepBarefeetDecalMatR2;
            }
        }        
    }
    else
    {
        // End:0xEF
        if(bLeftFoot)
        {
            // End:0xD9
            if(__NFUN_154__(__NFUN_167__(2), 0))
            {
                ParentMI = FootstepDecalMatL1;                
            }
            else
            {
                ParentMI = FootstepDecalMatL2;
            }            
        }
        else
        {
            // End:0x10F
            if(__NFUN_154__(__NFUN_167__(2), 0))
            {
                ParentMI = FootstepDecalMatR1;                
            }
            else
            {
                ParentMI = FootstepDecalMatR2;
            }
        }
    }
    DecalMI = new (self) Class'Engine.MaterialInstanceConstant';
    DecalMI.SetParent(ParentMI);
    DecalMI.SetScalarParameterValue('Opacity', Alpha);
    WorldInfo.MyDecalManager.SpawnDecal(DecalMI, DecalLocation, DecalRotation, 18.7500000, 37.5000000, 5.0000000, false, 0.0000000, none, false, false,,,, 90.0000000);
    //return;    
}

// Export UOLHero::execIsInMainMenu(FFrame&, void* const)
native function bool IsInMainMenu();

simulated event PlayFootStepSound(int FootDown, AnimNotify_Footstep footstepNotify)
{
    local name SurfaceMat;
    local float DecalAlpha;

    // End:0x79
    if(__NFUN_132__(__NFUN_132__(__NFUN_176__(WorldInfo.TimeSeconds, __NFUN_174__(LastFootstepTime, 0.2000000)), __NFUN_176__(WorldInfo.TimeSeconds, __NFUN_174__(SpawnTime, 0.7500000))), IsInMainMenu()))
    {
        return;
    }
    // End:0x2CB
    if(__NFUN_132__(__NFUN_177__(VSizeSq2D(OLPC.LastPlayerInputIntent), 25.0000000), footstepNotify.bNoVelocityRequired))
    {
        LastFootstepTime = WorldInfo.TimeSeconds;
        SurfaceMat = GetMaterialBelowFeet();
        SetSwitch(FloorMaterialGroup, SurfaceMat);
        // End:0x199
        if(__NFUN_132__(footstepNotify.bForceRunEvent, __NFUN_130__(IsRunning(), __NFUN_129__(footstepNotify.bForceWalkEvent))))
        {
            PlayAkEvent(FootStepSound_Run);            
        }
        else
        {
            PlayAkEvent(FootStepSound_Walk);
        }
        // End:0x2CB
        if(__NFUN_155__(int(WorldInfo.GetDetailMode()), int(0)))
        {
            // End:0x20B
            if(__NFUN_254__(SurfaceMat, WaterMaterial))
            {
                ActivateWaterFootstepParticles(__NFUN_154__(FootDown, 1));                
            }
            else
            {
                // End:0x235
                if(__NFUN_254__(SurfaceMat, BloodMaterial))
                {
                    RemainingBloodyFootsteps = NumBloodyFootsteps;
                }
            }
            // End:0x2CB
            if(__NFUN_151__(RemainingBloodyFootsteps, 0))
            {
                // End:0x278
                if(__NFUN_177__(float(RemainingBloodyFootsteps), __NFUN_171__(0.7500000, float(NumBloodyFootsteps))))
                {
                    DecalAlpha = 1.0000000;                    
                }
                else
                {
                    DecalAlpha = __NFUN_172__(float(RemainingBloodyFootsteps), __NFUN_171__(0.7500000, float(NumBloodyFootsteps)));
                }
                SpawnBloodFootstepDecal(__NFUN_154__(FootDown, 0), DecalAlpha);
                __NFUN_166__(RemainingBloodyFootsteps);
            }
        }
    }
    //return;    
}

event RespawnHero()
{
    local OLGame TheGame;
    local OLEngine Engine;

    // End:0x29B
    if(__NFUN_119__(OLPC, none))
    {
        TheGame = OLGame(WorldInfo.Game);
        // End:0x120
        if(__NFUN_130__(__NFUN_119__(TheGame, none), __NFUN_154__(int(TheGame.DifficultyMode), int(3))))
        {
            // End:0xCF
            if(Class'OLGame.OLUtils'.static.IsPlayingDLC())
            {
                OLPC.StartNewGameAtCheckpoint("Hospital_Start", false);                
            }
            else
            {
                OLPC.StartNewGameAtCheckpoint("Admin_Gates", false);
            }
            OLPC.bForceLevelReset = true;            
        }
        else
        {
            OLPC.UnPossess();
            __NFUN_279__();
            OLPC.PlayerDied();
            Class'OLGame.OLGameStateList'.static.OnPlayerDeath();
            Engine = OLEngine(Class'Engine.Engine'.static.GetEngine());
            TheGame = OLGame(WorldInfo.Game);
            // End:0x23A
            if(__NFUN_130__(__NFUN_119__(Engine, none), __NFUN_119__(Engine.CurrentCheckpointSave, none)))
            {
                Engine.StartCurrentCheckpoint();                
            }
            else
            {
                WorldInfo.Game.RestartPlayer(OLPC);
                OLPC.ClientSetCameraFade(false);
            }
        }
    }
    //return;    
}

simulated event FellOutOfWorld(Class<DamageType> dmgType)
{
    RespawnHero();
    //return;    
}

singular simulated event OutsideWorldBounds()
{
    RespawnHero();
    //return;    
}

function UpdateDifficultyBasedValues()
{
    local OLGame TheGame;

    TheGame = OLGame(WorldInfo.Game);
    // End:0x81
    if(__NFUN_132__(__NFUN_114__(TheGame, none), __NFUN_154__(int(TheGame.DifficultyMode), int(0))))
    {
        BatteryDuration = NrmBatteryDuration;        
    }
    else
    {
        BatteryDuration = HardBatteryDuration;
    }
    //return;    
}

defaultproperties
{
    // Reference: SkeletalMeshComponent'OLGame.Default__OLHero.ShadowProxyComponent'
    // TemplateOwnerClass: none
    // TemplateOwnerName: 'ShadowProxyComponent'
    begin object name="ShadowProxyComponent" class=Engine.SkeletalMeshComponent
        SkeletalMesh=SkeletalMesh'02_Player.Pawn.Miles_beheaded'
        AnimTreeTemplate=AnimTree'02_Behaviors.Player.Player_AnimTree'
        AnimSets[0]=AnimSet'03_Hero.Hero-01_AS'
        AnimSets[1]=AnimSet'03_OL_ScriptedEvents.Hero_SE'
        MinDistFactorForKinematicUpdate=0.2000000
        bUpdateKinematicBonesFromAnimation=false
        bOverrideAttachmentOwnerVisibility=true
        bChartDistanceFactor=true
        bCacheAnimSequenceNodes=false
        bNoAnimNotifies=true
        ReplacementPrimitive=none
        LightEnvironment=DynamicLightEnvironmentComponent'OLGame.Default__OLHero.MyLightEnvironment'
        RBChannel=ERBCollisionChannel.RBCC_Untitled3
        RBDominanceGroup=20
        HiddenGame=true
        bCastHiddenShadow=true
        LightingChannels=(bInitialized=true,Dynamic=true,Skybox=true,Unnamed_1=true,Unnamed_2=true,Unnamed_3=true,Unnamed_4=true,Unnamed_5=true,Unnamed_6=true,Cinematic_1=true,Cinematic_2=true,Cinematic_3=true,Cinematic_4=true,Cinematic_5=true,Dynamic_1=true,Dynamic_2=true,Dynamic_3=true,Dynamic_4=true,Dynamic_5=true,Gameplay_1=true,Gameplay_2=true,Gameplay_3=true,Gameplay_4=true)
    end object
    ShadowProxy=ShadowProxyComponent
    // Reference: StaticMeshComponent'OLGame.Default__OLHero.HeadMeshComp'
    // TemplateOwnerClass: none
    // TemplateOwnerName: 'HeadMeshComp'
    begin object name="HeadMeshComp" class=Engine.StaticMeshComponent
        StaticMesh=StaticMesh'02_Player.Pawn.Miles_head'
        ShadowParent=SkeletalMeshComponent'OLGame.Default__OLHero.ShadowProxyComponent'
        ReplacementPrimitive=none
        LightEnvironment=DynamicLightEnvironmentComponent'OLGame.Default__OLHero.MyLightEnvironment'
        HiddenGame=true
        bCastHiddenShadow=true
        CollideActors=false
        BlockActors=false
        LightingChannels=(bInitialized=true,Dynamic=true,Skybox=true,Unnamed_1=true,Unnamed_2=true,Unnamed_3=true,Unnamed_4=true,Unnamed_5=true,Unnamed_6=true,Cinematic_1=true,Cinematic_2=true,Cinematic_3=true,Cinematic_4=true,Cinematic_5=true,Dynamic_1=true,Dynamic_2=true,Dynamic_3=true,Dynamic_4=true,Dynamic_5=true,Gameplay_1=true,Gameplay_2=true,Gameplay_3=true,Gameplay_4=true)
    end object
    HeadMesh=HeadMeshComp
    // Reference: SkeletalMeshComponent'OLGame.Default__OLHero.CameraMeshComponent'
    // TemplateOwnerClass: none
    // TemplateOwnerName: 'CameraMeshComponent'
    begin object name="CameraMeshComponent" class=Engine.SkeletalMeshComponent
        SkeletalMesh=SkeletalMesh'01_Animated_Props.handycam'
        MinDistFactorForKinematicUpdate=0.2000000
        bUpdateSkelWhenNotRendered=false
        bIgnoreControllersWhenNotRendered=true
        bUpdateKinematicBonesFromAnimation=false
        bOverrideAttachmentOwnerVisibility=true
        bChartDistanceFactor=true
        ShadowParent=SkeletalMeshComponent'OLGame.Default__OLHero.ShadowProxyComponent'
        ReplacementPrimitive=none
        LightEnvironment=DynamicLightEnvironmentComponent'OLGame.Default__OLHero.MyLightEnvironment'
        RBDominanceGroup=20
        HiddenGame=true
        CastShadow=false
        bUseOnePassLightingOnTranslucency=true
        LightingChannels=(bInitialized=true,Dynamic=true,Skybox=true,Unnamed_1=true,Unnamed_2=true,Unnamed_3=true,Unnamed_4=true,Unnamed_5=true,Unnamed_6=true,Cinematic_1=true,Cinematic_2=true,Cinematic_3=true,Cinematic_4=true,Cinematic_5=true,Dynamic_1=true,Dynamic_2=true,Dynamic_3=true,Dynamic_4=true,Dynamic_5=true,Gameplay_1=true,Gameplay_2=true,Gameplay_3=true,Gameplay_4=true)
    end object
    CameraMesh=CameraMeshComponent
    // Reference: SkeletalMeshComponent'OLGame.Default__OLHero.CameraMeshShadowProxyComponent'
    // TemplateOwnerClass: none
    // TemplateOwnerName: 'CameraMeshShadowProxyComponent'
    begin object name="CameraMeshShadowProxyComponent" class=Engine.SkeletalMeshComponent
        SkeletalMesh=SkeletalMesh'01_Animated_Props.handycam.handycamShadow'
        MinDistFactorForKinematicUpdate=0.2000000
        bUpdateSkelWhenNotRendered=false
        bIgnoreControllersWhenNotRendered=true
        bUpdateKinematicBonesFromAnimation=false
        bOverrideAttachmentOwnerVisibility=true
        bChartDistanceFactor=true
        ShadowParent=SkeletalMeshComponent'OLGame.Default__OLHero.ShadowProxyComponent'
        ReplacementPrimitive=none
        LightEnvironment=DynamicLightEnvironmentComponent'OLGame.Default__OLHero.MyLightEnvironment'
        RBDominanceGroup=20
        HiddenGame=true
        bUseOnePassLightingOnTranslucency=true
        LightingChannels=(bInitialized=true,Dynamic=true,Skybox=true,Unnamed_1=true,Unnamed_2=true,Unnamed_3=true,Unnamed_4=true,Unnamed_5=true,Unnamed_6=true,Cinematic_1=true,Cinematic_2=true,Cinematic_3=true,Cinematic_4=true,Cinematic_5=true,Dynamic_1=true,Dynamic_2=true,Dynamic_3=true,Dynamic_4=true,Dynamic_5=true,Gameplay_1=true,Gameplay_2=true,Gameplay_3=true,Gameplay_4=true)
    end object
    CameraMeshShadowProxy=CameraMeshShadowProxyComponent
    // Reference: ParticleSystemComponent'OLGame.Default__OLHero.BloodEffectComponent'
    // TemplateOwnerClass: none
    // TemplateOwnerName: 'BloodEffectComponent'
    begin object name="BloodEffectComponent" class=Engine.ParticleSystemComponent
        Template=ParticleSystem'VFX_Blood.Particles.Player_Death_blood'
        bAutoActivate=false
        ReplacementPrimitive=none
        DepthPriorityGroup=ESceneDepthPriorityGroup.SDPG_Foreground
    end object
    BloodEffect=BloodEffectComponent
    // Reference: ParticleSystemComponent'OLGame.Default__OLHero.DeathParticlesComponent'
    // TemplateOwnerClass: none
    // TemplateOwnerName: 'DeathParticlesComponent'
    begin object name="DeathParticlesComponent" class=Engine.ParticleSystemComponent
        Template=ParticleSystem'VFX_Blood.Particles.Camera_Blood_splash'
        bAutoActivate=false
        ReplacementPrimitive=none
        DepthPriorityGroup=ESceneDepthPriorityGroup.SDPG_Foreground
    end object
    DeathParticles=DeathParticlesComponent
    // Reference: ParticleSystemComponent'OLGame.Default__OLHero.DecapitatedEffectComponent'
    // TemplateOwnerClass: none
    // TemplateOwnerName: 'DecapitatedEffectComponent'
    begin object name="DecapitatedEffectComponent" class=Engine.ParticleSystemComponent
        Template=ParticleSystem'VFX_Blood.Particles.PlayerHeadlessBloodLit-01'
        bAutoActivate=false
        ReplacementPrimitive=none
    end object
    DecapitatedBloodEffect=DecapitatedEffectComponent
    // Reference: ParticleSystemComponent'OLGame.Default__OLHero.RainEffectComponent'
    // TemplateOwnerClass: none
    // TemplateOwnerName: 'RainEffectComponent'
    begin object name="RainEffectComponent" class=Engine.ParticleSystemComponent
        Template=ParticleSystem'VFX_Camera.CameraRainDrop-01'
        bAutoActivate=false
        SecondsBeforeInactive=45.0000000
        ReplacementPrimitive=none
        DepthPriorityGroup=ESceneDepthPriorityGroup.SDPG_Foreground
    end object
    RainEffect=RainEffectComponent
    // Reference: ParticleSystemComponent'OLGame.Default__OLHero.WaterFootstepLeftComp'
    // TemplateOwnerClass: none
    // TemplateOwnerName: 'WaterFootstepLeftComp'
    begin object name="WaterFootstepLeftComp" class=Engine.ParticleSystemComponent
        Template=ParticleSystem'VFX_water.Particle.PLAYER_FootStepSplash-01'
        bAutoActivate=false
        ReplacementPrimitive=none
        LightEnvironment=ParticleLightEnvironmentComponent'OLGame.Default__OLHero.FootstepsLightEnvironment'
    end object
    WaterFootstepParticlesLeft=WaterFootstepLeftComp
    // Reference: ParticleSystemComponent'OLGame.Default__OLHero.WaterFootstepRightComp'
    // TemplateOwnerClass: none
    // TemplateOwnerName: 'WaterFootstepRightComp'
    begin object name="WaterFootstepRightComp" class=Engine.ParticleSystemComponent
        Template=ParticleSystem'VFX_water.Particle.PLAYER_FootStepSplash-01'
        bAutoActivate=false
        ReplacementPrimitive=none
        LightEnvironment=ParticleLightEnvironmentComponent'OLGame.Default__OLHero.FootstepsLightEnvironment'
    end object
    WaterFootstepParticlesRight=WaterFootstepRightComp
    // Reference: ParticleSystemComponent'OLGame.Default__OLHero.WaterSplashParticlesComp'
    // TemplateOwnerClass: none
    // TemplateOwnerName: 'WaterSplashParticlesComp'
    begin object name="WaterSplashParticlesComp" class=Engine.ParticleSystemComponent
        Template=ParticleSystem'VFX_water.Particle.PLAYER_WaterSplash-01'
        bAutoActivate=false
        ReplacementPrimitive=none
        LightEnvironment=ParticleLightEnvironmentComponent'OLGame.Default__OLHero.FootstepsLightEnvironment'
    end object
    WaterSplashParticles=WaterSplashParticlesComp
    // Reference: ParticleSystemComponent'OLGame.Default__OLHero.CameraEffectComponent'
    // TemplateOwnerClass: none
    // TemplateOwnerName: 'CameraEffectComponent'
    begin object name="CameraEffectComponent" class=Engine.ParticleSystemComponent
        bAutoActivate=false
        ReplacementPrimitive=none
        DepthPriorityGroup=ESceneDepthPriorityGroup.SDPG_Foreground
    end object
    GenericCameraEffect=CameraEffectComponent
    // Reference: SpotLightComponent'OLGame.Default__OLHero.NVLightComponent'
    // TemplateOwnerClass: none
    // TemplateOwnerName: 'NVLightComponent'
    begin object name="NVLightComponent" class=Engine.SpotLightComponent
        InnerConeAngle=10.0000000
        OuterConeAngle=35.0000000
        Radius=940.0000000
        LightmassSettings=(LightSourceRadius=32.0000000)
        Brightness=0.0500000
        bEnabled=false
        CastShadows=false
        bForceDynamicLight=true
        bPrecomputedLightingIsValid=false
        LightingChannels=(Skybox=true,Unnamed_1=true,Unnamed_2=true,Unnamed_3=true,Unnamed_4=true,Unnamed_5=true,Unnamed_6=true,Cinematic_1=true,Cinematic_2=true,Cinematic_3=true,Cinematic_4=true,Cinematic_5=true,Dynamic_1=true,Dynamic_2=true,Dynamic_3=true,Dynamic_4=true,Dynamic_5=true,Gameplay_1=true,Gameplay_2=true,Gameplay_3=true,Gameplay_4=true)
        LightAffectsClassification=ELightAffectsClassification.LAC_DYNAMIC_AND_STATIC_AFFECTING
        LightShadowMode=ELightShadowMode.LightShadow_Normal
    end object
    NVLightPowered=NVLightComponent
    // Reference: SpotLightComponent'OLGame.Default__OLHero.NVLightNoBatteriesComponent'
    // TemplateOwnerClass: none
    // TemplateOwnerName: 'NVLightNoBatteriesComponent'
    begin object name="NVLightNoBatteriesComponent" class=Engine.SpotLightComponent
        InnerConeAngle=10.0000000
        OuterConeAngle=35.0000000
        Radius=300.0000000
        LightmassSettings=(LightSourceRadius=32.0000000)
        Brightness=0.0200000
        bEnabled=false
        CastShadows=false
        bForceDynamicLight=true
        bPrecomputedLightingIsValid=false
        LightingChannels=(Skybox=true,Unnamed_1=true,Unnamed_2=true,Unnamed_3=true,Unnamed_4=true,Unnamed_5=true,Unnamed_6=true,Cinematic_1=true,Cinematic_2=true,Cinematic_3=true,Cinematic_4=true,Cinematic_5=true,Dynamic_1=true,Dynamic_2=true,Dynamic_3=true,Dynamic_4=true,Dynamic_5=true,Gameplay_1=true,Gameplay_2=true,Gameplay_3=true,Gameplay_4=true)
        LightAffectsClassification=ELightAffectsClassification.LAC_DYNAMIC_AND_STATIC_AFFECTING
        LightShadowMode=ELightShadowMode.LightShadow_Normal
    end object
    NVLightDefault=NVLightNoBatteriesComponent
    // Reference: SpotLightComponent'OLGame.Default__OLHero.DarkLightComponent'
    // TemplateOwnerClass: none
    // TemplateOwnerName: 'DarkLightComponent'
    begin object name="DarkLightComponent" class=Engine.SpotLightComponent
        InnerConeAngle=30.0000000
        OuterConeAngle=60.0000000
        Radius=100.0000000
        LightmassSettings=(LightSourceRadius=32.0000000)
        Brightness=0.0100000
        CastShadows=false
        bForceDynamicLight=true
        bPrecomputedLightingIsValid=false
        LightingChannels=(Skybox=true,Unnamed_1=true,Unnamed_2=true,Unnamed_3=true,Unnamed_4=true,Unnamed_5=true,Unnamed_6=true,Cinematic_1=true,Cinematic_2=true,Cinematic_3=true,Cinematic_4=true,Cinematic_5=true,Dynamic_1=true,Dynamic_2=true,Dynamic_3=true,Dynamic_4=true,Dynamic_5=true,Gameplay_1=true,Gameplay_2=true,Gameplay_3=true,Gameplay_4=true)
        LightAffectsClassification=ELightAffectsClassification.LAC_DYNAMIC_AND_STATIC_AFFECTING
        LightShadowMode=ELightShadowMode.LightShadow_Normal
    end object
    DarkLight=DarkLightComponent
    // Reference: PointLightComponent'OLGame.Default__OLHero.CamcorderScreenLightComp'
    // TemplateOwnerClass: none
    // TemplateOwnerName: 'CamcorderScreenLightComp'
    begin object name="CamcorderScreenLightComp" class=Engine.PointLightComponent
        Radius=10.0000000
        FalloffExponent=8.0000000
        LightmassSettings=(LightSourceRadius=5.0000000)
        Brightness=0.5000000
        LightColor=(R=191,G=255,B=198,A=0)
        bPrecomputedLightingIsValid=false
        LightAffectsClassification=ELightAffectsClassification.LAC_DYNAMIC_AND_STATIC_AFFECTING
        LightShadowMode=ELightShadowMode.LightShadow_Normal
    end object
    CamcorderScreenLight=CamcorderScreenLightComp
    FingerlessMesh=SkeletalMesh'02_Player.Pawn.Miles_beheaded_fingerless'
    ITTechMesh=SkeletalMesh'02_Waylon_Park.Mesh.Waylon_Park_IT'
    PrisonerMesh=SkeletalMesh'02_Waylon_Park.Mesh.Waylon_Park'
    FootstepDecalMatL1=MaterialInstanceConstant'Decals.Blood.FootPrint_L1_mat'
    FootstepDecalMatL2=MaterialInstanceConstant'Decals.Blood.FootPrint_L2_mat'
    FootstepDecalMatR1=MaterialInstanceConstant'Decals.Blood.FootPrint_R1_mat'
    FootstepDecalMatR2=MaterialInstanceConstant'Decals.Blood.FootPrint_R2_mat'
    FootstepBarefeetDecalMatL1=MaterialInstanceConstant'Decals_DLC.Blood.FootPrint-02_L1_mat'
    FootstepBarefeetDecalMatL2=MaterialInstanceConstant'Decals_DLC.Blood.FootPrint-02_L2_mat'
    FootstepBarefeetDecalMatR1=MaterialInstanceConstant'Decals_DLC.Blood.FootPrint-02_R1_mat'
    FootstepBarefeetDecalMatR2=MaterialInstanceConstant'Decals_DLC.Blood.FootPrint-02_R2_mat'
    CameraScreenMat=MaterialInstanceConstant'01_Animated_Props.handycam.CameraScreen_INST'
    CameraScreenParamName="nvOn"
    LeftHandBoneName="Hero-L-Hand"
    LeftHandAuxBoneName="Hero-L-Hand_aux"
    RightHandAuxBoneName="Hero-R-Hand_aux"
    OverriddenMinCamcorderFOV=-1.0000000
    LocomotionModeParams[0]=(GP=(RMM=ERootMotionMode.RMM_Ignore,CameraMode=CameraRotationMode.CRM_UserControlled,MinYaw=0.0000000,MaxYaw=0.0000000,MinPitchWS=-84.0000000,MaxPitchWS=70.0000000,MinPitchCS=-84.0000000,MaxPitchCS=84.0000000,ViewLimitsApproachCoeff=0.9900000,FOVOverride=-1.0000000,DisableCollisions=false,IgnorePawnCollisions=false,CollisionHeight=-1.0000000,CollisionRadius=-1.0000000,Physics=EPhysics.PHYS_Walking,BothHandsNeeded=false),NeckOffsetSide=0.0000000,NeckOffsetFwd=0.0000000)
    LocomotionModeParams[1]=(GP=(RMM=ERootMotionMode.RMM_Ignore,CameraMode=CameraRotationMode.CRM_UserControlled,MinYaw=0.0000000,MaxYaw=0.0000000,MinPitchWS=-84.0000000,MaxPitchWS=70.0000000,MinPitchCS=-84.0000000,MaxPitchCS=84.0000000,ViewLimitsApproachCoeff=0.9900000,FOVOverride=-1.0000000,DisableCollisions=false,IgnorePawnCollisions=false,CollisionHeight=-1.0000000,CollisionRadius=-1.0000000,Physics=EPhysics.PHYS_Falling,BothHandsNeeded=false),NeckOffsetSide=0.0000000,NeckOffsetFwd=0.0000000)
    LocomotionModeParams[2]=(GP=(RMM=ERootMotionMode.RMM_Ignore,CameraMode=CameraRotationMode.CRM_UserControlled,MinYaw=0.0000000,MaxYaw=0.0000000,MinPitchWS=-84.0000000,MaxPitchWS=70.0000000,MinPitchCS=-84.0000000,MaxPitchCS=84.0000000,ViewLimitsApproachCoeff=0.9900000,FOVOverride=-1.0000000,DisableCollisions=false,IgnorePawnCollisions=false,CollisionHeight=-1.0000000,CollisionRadius=-1.0000000,Physics=EPhysics.PHYS_Custom,BothHandsNeeded=false),NeckOffsetSide=0.0000000,NeckOffsetFwd=0.0000000)
    LocomotionModeParams[3]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Spring,MinYaw=-60.0000000,MaxYaw=60.0000000,MinPitchWS=10.0000000,MaxPitchWS=80.0000000,MinPitchCS=-84.0000000,MaxPitchCS=84.0000000,ViewLimitsApproachCoeff=0.9900000,FOVOverride=-1.0000000,DisableCollisions=false,IgnorePawnCollisions=false,CollisionHeight=-1.0000000,CollisionRadius=15.0000000,Physics=EPhysics.PHYS_Custom,BothHandsNeeded=true),NeckOffsetSide=6.0000000,NeckOffsetFwd=6.0000000)
    LocomotionModeParams[4]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-85.0000000,MaxYaw=85.0000000,MinPitchWS=5.0000000,MaxPitchWS=80.0000000,MinPitchCS=-84.0000000,MaxPitchCS=84.0000000,ViewLimitsApproachCoeff=0.9900000,FOVOverride=-1.0000000,DisableCollisions=false,IgnorePawnCollisions=false,CollisionHeight=-1.0000000,CollisionRadius=15.0000000,Physics=EPhysics.PHYS_Custom,BothHandsNeeded=true),NeckOffsetSide=8.0000000,NeckOffsetFwd=2.0000000)
    LocomotionModeParams[5]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-70.0000000,MaxYaw=70.0000000,MinPitchWS=-80.0000000,MaxPitchWS=60.0000000,MinPitchCS=-84.0000000,MaxPitchCS=84.0000000,ViewLimitsApproachCoeff=0.9900000,FOVOverride=-1.0000000,DisableCollisions=false,IgnorePawnCollisions=false,CollisionHeight=-1.0000000,CollisionRadius=5.0000000,Physics=EPhysics.PHYS_Custom,BothHandsNeeded=false),NeckOffsetSide=14.0000000,NeckOffsetFwd=2.0000000)
    LocomotionModeParams[6]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-85.0000000,MaxYaw=85.0000000,MinPitchWS=-15.0000000,MaxPitchWS=40.0000000,MinPitchCS=-84.0000000,MaxPitchCS=84.0000000,ViewLimitsApproachCoeff=0.6000000,FOVOverride=-1.0000000,DisableCollisions=false,IgnorePawnCollisions=false,CollisionHeight=-1.0000000,CollisionRadius=5.0000000,Physics=EPhysics.PHYS_Custom,BothHandsNeeded=false),NeckOffsetSide=14.0000000,NeckOffsetFwd=-6.0000000)
    LocomotionModeParams[7]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-30.0000000,MaxYaw=30.0000000,MinPitchWS=-30.0000000,MaxPitchWS=30.0000000,MinPitchCS=-84.0000000,MaxPitchCS=84.0000000,ViewLimitsApproachCoeff=0.9900000,FOVOverride=-1.0000000,DisableCollisions=false,IgnorePawnCollisions=false,CollisionHeight=-1.0000000,CollisionRadius=5.0000000,Physics=EPhysics.PHYS_Custom,BothHandsNeeded=false),NeckOffsetSide=0.0000000,NeckOffsetFwd=0.0000000)
    LocomotionModeParams[8]=(GP=(RMM=ERootMotionMode.RMM_Ignore,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-45.0000000,MaxYaw=45.0000000,MinPitchWS=-40.0000000,MaxPitchWS=40.0000000,MinPitchCS=-84.0000000,MaxPitchCS=84.0000000,ViewLimitsApproachCoeff=0.9900000,FOVOverride=-1.0000000,DisableCollisions=false,IgnorePawnCollisions=false,CollisionHeight=-1.0000000,CollisionRadius=10.0000000,Physics=EPhysics.PHYS_Custom,BothHandsNeeded=false),NeckOffsetSide=0.0000000,NeckOffsetFwd=0.0000000)
    LocomotionModeParams[9]=(GP=(RMM=ERootMotionMode.RMM_Ignore,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-180.0000000,MaxYaw=180.0000000,MinPitchWS=-80.0000000,MaxPitchWS=80.0000000,MinPitchCS=-84.0000000,MaxPitchCS=84.0000000,ViewLimitsApproachCoeff=0.9900000,FOVOverride=-1.0000000,DisableCollisions=false,IgnorePawnCollisions=false,CollisionHeight=-1.0000000,CollisionRadius=-1.0000000,Physics=EPhysics.PHYS_Custom,BothHandsNeeded=false),NeckOffsetSide=0.0000000,NeckOffsetFwd=0.0000000)
    LocomotionModeParams[10]=(GP=(RMM=ERootMotionMode.RMM_Ignore,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-95.0000000,MaxYaw=95.0000000,MinPitchWS=-15.0000000,MaxPitchWS=15.0000000,MinPitchCS=-84.0000000,MaxPitchCS=84.0000000,ViewLimitsApproachCoeff=0.9900000,FOVOverride=110.0000000,DisableCollisions=false,IgnorePawnCollisions=false,CollisionHeight=5.0000000,CollisionRadius=20.0000000,Physics=EPhysics.PHYS_Custom,BothHandsNeeded=false),NeckOffsetSide=8.0000000,NeckOffsetFwd=0.0000000)
    LocomotionModeParams[11]=(GP=(RMM=ERootMotionMode.RMM_Ignore,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-10.0000000,MaxYaw=10.0000000,MinPitchWS=-15.0000000,MaxPitchWS=15.0000000,MinPitchCS=-84.0000000,MaxPitchCS=84.0000000,ViewLimitsApproachCoeff=0.9999990,FOVOverride=110.0000000,DisableCollisions=false,IgnorePawnCollisions=false,CollisionHeight=-1.0000000,CollisionRadius=-1.0000000,Physics=EPhysics.PHYS_Walking,BothHandsNeeded=false),NeckOffsetSide=0.0000000,NeckOffsetFwd=0.0000000)
    LocomotionModeParams[12]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_FullyAnimated,MinYaw=0.0000000,MaxYaw=0.0000000,MinPitchWS=-84.0000000,MaxPitchWS=70.0000000,MinPitchCS=-84.0000000,MaxPitchCS=84.0000000,ViewLimitsApproachCoeff=0.9900000,FOVOverride=-1.0000000,DisableCollisions=false,IgnorePawnCollisions=false,CollisionHeight=-1.0000000,CollisionRadius=-1.0000000,Physics=EPhysics.PHYS_Custom,BothHandsNeeded=true),NeckOffsetSide=8.0000000,NeckOffsetFwd=5.0000000)
    LocomotionModeParams[13]=(GP=(RMM=ERootMotionMode.RMM_Ignore,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-30.0000000,MaxYaw=30.0000000,MinPitchWS=-2.0000000,MaxPitchWS=50.0000000,MinPitchCS=-84.0000000,MaxPitchCS=84.0000000,ViewLimitsApproachCoeff=0.9900000,FOVOverride=-1.0000000,DisableCollisions=false,IgnorePawnCollisions=false,CollisionHeight=-1.0000000,CollisionRadius=-1.0000000,Physics=EPhysics.PHYS_Custom,BothHandsNeeded=false),NeckOffsetSide=0.0000000,NeckOffsetFwd=0.0000000)
    LocomotionModeParams[14]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-30.0000000,MaxYaw=30.0000000,MinPitchWS=-84.0000000,MaxPitchWS=70.0000000,MinPitchCS=-30.0000000,MaxPitchCS=30.0000000,ViewLimitsApproachCoeff=0.9900000,FOVOverride=-1.0000000,DisableCollisions=false,IgnorePawnCollisions=false,CollisionHeight=-1.0000000,CollisionRadius=-1.0000000,Physics=EPhysics.PHYS_Custom,BothHandsNeeded=true),NeckOffsetSide=0.0000000,NeckOffsetFwd=0.0000000)
    LocomotionModeParams[15]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-50.0000000,MaxYaw=50.0000000,MinPitchWS=-84.0000000,MaxPitchWS=70.0000000,MinPitchCS=-60.0000000,MaxPitchCS=60.0000000,ViewLimitsApproachCoeff=0.9900000,FOVOverride=-1.0000000,DisableCollisions=false,IgnorePawnCollisions=false,CollisionHeight=-1.0000000,CollisionRadius=-1.0000000,Physics=EPhysics.PHYS_Custom,BothHandsNeeded=false),NeckOffsetSide=0.0000000,NeckOffsetFwd=0.0000000)
    NumAIPositions=64.0000000
    AIPositionDistance=130.0000000
    AIPositionLayerBuffer=70.0000000
    NumAIPositionsPerSidePerPawn=3
    NumAIPositionsToCheckPerFrame=8
    NumAvgVelPoints=10.0000000
    AvgVelPointLength=1.0000000
    FirstFingerlessCheckpoint="Male_TortureDone"
    ShatteredCameraGlassCheckpoint="Female_LostCam"
    ITUniformCheckpoint="DLC_Lab_Start"
    PrisonerUniformCheckpoint="Hospital_Start"
    NormalWalkSpeed=200.0000000
    NormalRunSpeed=450.0000000
    CrouchedSpeed=75.0000000
    ElectrifiedSpeed=100.0000000
    WaterWalkSpeed=100.0000000
    WaterRunSpeed=200.0000000
    LimpingWalkSpeed=87.2430000
    HobblingWalkSpeed=140.0000000
    HobblingRunSpeed=250.0000000
    SpeedPenaltyBackwards=0.3500000
    SpeedPenaltyStrafe=0.2000000
    ForwardSpeedForJumpWalking=450.0000000
    ForwardSpeedForJumpRunning=650.0000000
    JumpClearanceWalking=200.0000000
    JumpClearanceRunning=300.0000000
    LandingPenaltyDuration=1.0000000
    LandingSpeedModifier=0.2500000
    ElectrifiedJumpDelay=0.2500000
    ExternalImpulseDecelCoeff=0.9700000
    ExternalImpulseMinVel=60.0000000
    ExternalImpulseMaxVel=1500.0000000
    ExternalImpulseMaxVelCrouched=750.0000000
    FallSpeedForDamage=1250.0000000
    FallSpeedForDeath=1500.0000000
    FallDamageExponent=1.5000000
    DefaultFOV=90.0000000
    RunningFOV=100.0000000
    FOVApproachCoeffOpening=0.9700000
    FOVApproachCoeffClosing=0.9700000
    FOVApproachCoeffRun=0.4000000
    FOVApproachCoeffWalk=0.9700000
    NrmBatteryDuration=150.0000000
    HardBatteryDuration=150.0000000
    CamcorderMinFOV=15.0000000
    CamcorderMaxFOV=83.0000000
    CamcorderNVMaxFOV=83.0000000
    NVLightZoomedInInnerAngle=2.0000000
    NVLightZoomedInOuterAngle=5.0000000
    NVLightZoomedInRadius=1500.0000000
    NVLightZoomedInBrightness=0.0250000
    DarkLightBrightnessDefault=0.0100000
    DarkLightRadiusDefault=100.0000000
    DarkLightBrightnessNoCamcorder=0.0300000
    DarkLightRadiusNoCamcorder=175.0000000
    DarkLightBrightnessBothHandsNeeded=0.0300000
    DarkLightRadiusBothHandsNeeded=125.0000000
    DarkLightBrightnessAttacked=0.0250000
    DarkLightRadiusAttacked=140.0000000
    DarkLightBrightnessParrying=0.0150000
    DarkLightRadiusParrying=140.0000000
    NVGlitchTimeThreshold=25.0000000
    NVGlitchMaxDelayStart=8.0000000
    NVGlitchMaxDelayEnd=5.0000000
    NVGlitchMinDuration=0.5000000
    NVGlitchMaxDuration=3.0000000
    NVGlitchMaxLevel=0.5000000
    HealthRegenRate=10.0000000
    HealthRegenDelay=10.0000000
    HobbleApproachRate=0.0500000
    ElectricEffectPeriod=0.4000000
    ElectricEffectBase=0.4000000
    ElectricEffectMode=2
    ElectricHurtSoundInterval=0.8000000
    DeathScreenDuration=7.5000000
    NumBloodyFootsteps=12
    HeatDamageDist=150.0000000
    HeatDamageInterval=0.6000000
    HeatDamagePerSec=15.0000000
    HeatMaxBlurDist=75.0000000
    HeatMinBlurDist=250.0000000
    HeatMinBlurAmount=0.8000000
    HeatBlurApproachCoeffIn=0.9900000
    HeatBlurApproachCoeffOut=0.5000000
    MinCosAngleForPickup=0.9800000
    PickupInteractRadius=30.0000000
    JumpForwardFromLedgeWalkXYSpeed=400.0000000
    JumpForwardFromLedgeWalkZSpeed=350.0000000
    DropFromLedgeWalkXYSpeed=150.0000000
    DropFromLedgeWalkZSpeed=300.0000000
    LookBackCamRotOffset=155.0000000
    LookBackCamBackOffset=60.0000000
    LookBackCamSideOffset=20.0000000
    LeanSpeedThreshold=25.0000000
    WalkingLoudness=0.3000000
    CrouchLoudness=0.1000000
    RunningLoudness=1.0000000
    WalkingWaterLoudness=0.4500000
    CrouchWaterLoudness=0.1000000
    HobblingWalkLoudness=0.4000000
    HobblingRunLoudness=1.0000000
    LandingBigLoudness=0.8000000
    LandingSmallLoudness=0.3000000
    LandingBigWaterLoudness=1.0000000
    LandingSmallWaterLoudness=0.5000000
    DoorOpenInstantLoudness=0.6000000
    DoorOpenPartialLoudness=0.3000000
    DoorCloseFastLoudness=0.3000000
    DoorEnterLockerLoudness=0.2000000
    DoorExitLockerLoudness=0.2000000
    DoorRunThroughLoudness=1.0000000
    MovingNoiseStartTime=1.7500000
    MovingNoiseClearTime=1.0000000
    CrouchNoise="Crouch"
    WalkingNoise="Walking"
    RunningNoise="Running"
    DoorMajorNoise="DoorMajor"
    MovingNoiseRate=0.0330000
    WaterMaterial="Water"
    BloodMaterial="Blood"
    // Reference: ForceFeedbackWaveform'OLGame.Default__OLHero.BigLandingWFComp'
    begin object name="BigLandingWFComp" class=Engine.ForceFeedbackWaveform
        Samples=/* Array type was not detected. */
    end object
    BigLandingFFWaveform=BigLandingWFComp
    // Reference: ForceFeedbackWaveform'OLGame.Default__OLHero.SmallLandingWFComp'
    begin object name="SmallLandingWFComp" class=Engine.ForceFeedbackWaveform
        Samples=/* Array type was not detected. */
    end object
    SmallLandingFFWaveform=SmallLandingWFComp
    // Reference: ForceFeedbackWaveform'OLGame.Default__OLHero.PickupWFComp'
    begin object name="PickupWFComp" class=Engine.ForceFeedbackWaveform
        Samples=/* Array type was not detected. */
    end object
    PickupFFWaveform=PickupWFComp
    // Reference: ForceFeedbackWaveform'OLGame.Default__OLHero.DoorWFComp'
    begin object name="DoorWFComp" class=Engine.ForceFeedbackWaveform
        Samples=/* Array type was not detected. */
    end object
    DoorInteractionFFWaveform=DoorWFComp
    // Reference: ForceFeedbackWaveform'OLGame.Default__OLHero.RunThroughDoorWFComp'
    begin object name="RunThroughDoorWFComp" class=Engine.ForceFeedbackWaveform
        Samples=/* Array type was not detected. */
    end object
    RunThroughDoorFFWaveform=RunThroughDoorWFComp
    FootStepSound_Run=AkEvent'Player_Sound.Footsteps_Run_Miles'
    SndCamStart=AkEvent'Player_Sound.CAM_Start_Using'
    SndCamStop=AkEvent'Player_Sound.CAM_Stop_Using'
    SndCamOnNVOn=AkEvent'Player_Sound.CAM_On_SwitchON_NV'
    SndCamOnNVOff=AkEvent'Player_Sound.CAM_On_SwitchOFF_NV'
    SndCamOffNVOn=AkEvent'Player_Sound.CAM_Off_SwitchON_NV'
    SndCamOffNVOff=AkEvent'Player_Sound.CAM_Off_SwitchOFF_NV'
    SndReloadBatteries=AkEvent'Player_Sound.CAM_Reload_Battery'
    SndPickupDocument=AkEvent'Player_Sound.Pick_Up_Document'
    SndPickupBatteries=AkEvent'Player_Sound.Pick_Up_Battery'
    SndZoomIn=AkEvent'General_Sound.EV_Zoom_IN_Cam'
    SndZoomOut=AkEvent'General_Sound.EV_Zoom_OUT_Cam'
    SndSoldierHit=AkEvent'General_Sound.EV_Soldier_Hit'
    SndDie=AkEvent'VO_Miles.VO_MILES_DIE'
    SndHit=AkEvent'VO_Miles.VO_MILES_HIT_INTENSITY'
    SndHitElectrified=AkEvent'VO_Miles.VO_MILES_HIT_INTENSITY'
    SndStartPeek=AkEvent'VO_Miles.VO_MILES_PEK_INSPI'
    SndStopPeek=AkEvent'VO_Miles.VO_MILES_PEK_EXPI'
    SndStartDamage=AkEvent'Player_Sound.DAMAGES_Health_Play'
    SndStopDamage=AkEvent'Player_Sound.DAMAGES_Health_Stop'
    SndElectricHitStart=AkEvent'SFX.Play_Loop_Electric'
    SndElectricHitStop=AkEvent'SFX.Stop_Loop_Electric'
    SndStartRun=AkEvent'VO_Miles.VO_MILES_RUN_BREATH'
    SndStopRun=AkEvent'VO_Miles.VO_MILES_RUN_STOP'
    SndStartLookBack=AkEvent'SFX.Play_WHOOSH_LOOKBACK'
    SndStopLookBack=AkEvent'SFX.Play_WHOOSH_LOOKFRONT'
    SndSmallLanding=AkEvent'Player_Sound.Landing_Soft_Miles'
    SndBigLanding=AkEvent'Player_Sound.Landing_Strong_Miles'
    SndDieMusicEvent=AkEvent'General_Sound.MUS_MILES_DEATH'
    SndNewObjective=AkEvent'General_Sound.SFX_SetObjectif'
    SndRecordingCompleted=AkEvent'General_Sound.SFX_RecordingMoment_Done'
    SndLowBatteryStart=AkEvent'Player_Sound.CAM_Light_Intensity'
    SndLowBatteryStop=AkEvent'Player_Sound.CAM_Light_Intensity_Stop'
    StateHitIntensityGroup="HIT_Intensity"
    StateHitIntensityLow="HIT_Low"
    StateHitIntensityMed="HIT_Medium"
    StateHitIntensityHigh="HIT_Hight"
    RTPCHealth="Health"
    RTPCZoom="Zoom"
    RTPCBatteryIntensity="Light_Cam_Intensity"
    AnimNameJumpFromWalk="player_jump_from_run"
    AnimNameJumpFromRun="player_jump_from_run"
    AnimNameJumpOverFromWalk="player_jump_over_from_walk"
    AnimNameJumpOverFromRun="player_jump_over_from_run"
    AnimNameJumpOverToGrabLedge="player_jump_over_to_ledge"
    AnimNameClimbUpFromWalk="player_climb_up_from_walk"
    AnimNameClimbUpFromRun="player_climb_up_from_run"
    AnimNameClimbUpToCrouch="player_climb_up_from_walk_to_crouch"
    AnimNameClimbUpWall150="player_climb_up_wall_1pt5m"
    AnimNameClimbUpWall200="player_climb_up_wall_2m"
    AnimNameClimbOverWall200="player_climb_over_wall_2m"
    AnimNameCrouch="player_stand_to_crouch"
    AnimNameUncrouch="player_crouch_to_stand"
    AnimNameLedgeHangLeftInside="player_ledge_move_left_90_inside"
    AnimNameLedgeHangRightInside="player_ledge_move_right_90_inside"
    AnimNameLedgeHangLeftOutside="player_ledge_move_left_90_outside"
    AnimNameLedgeHangRightOutside="player_ledge_move_right_90_outside"
    AnimNameClimbUpLedgeToCrouch="player_climb_ledge_to_crouch"
    AnimNameClimbUpLedgeToStand="player_climb_ledge_to_stand"
    AnimNameClimbOverLedgeToFalling="player_ledge_hang_climb_over_to_fall"
    AnimNameClimbOverLedgeToStand="player_ledge_hang_climb_over"
    AnimNameSlideOverFromRun="player_slide_over_from_run"
    AnimNameGrabAndClimb="player_falling_forward_hit_ledge"
    AnimNameGrabLedgeFromAir="player_grab_ledge_from_air"
    AnimNameGrabLedgeFromWalkHigh="player_jump_to_ledge_from_walk"
    AnimNameGrabLedgeFromWalkLow="player_jump_to_ledge_from_walk_2m"
    AnimNameLandingSmallStanding="player_landing_small"
    AnimNameLandingSmallCrouched="player_crouch_land_small"
    AnimNameBigLandingStanding="player_landing_big"
    AnimNameBigLandingCrouched="player_crouch_land_big"
    AnimNameEnterLedgeWalkInsideLeftPerp="player_ledge_walk_enter_left_inside_perp"
    AnimNameEnterLedgeWalkInsideLeftPrl="player_ledge_walk_enter_left_inside_prl"
    AnimNameEnterLedgeWalkInsideRightPerp="player_ledge_walk_enter_right_inside_perp"
    AnimNameEnterLedgeWalkInsideRightPrl="player_ledge_walk_enter_right_inside_prl"
    AnimNameEnterLedgeWalkOutsideLeftPerp="player_ledge_walk_enter_left_outside_perp"
    AnimNameEnterLedgeWalkOutsideLeftPrl="player_ledge_walk_enter_left_outside_prl"
    AnimNameEnterLedgeWalkOutsideRightPerp="player_ledge_walk_enter_right_outside_perp"
    AnimNameEnterLedgeWalkOutsideRightPrl="player_ledge_walk_enter_right_outside_prl"
    AnimNameLedgeWalkTransitionLeftInside="player_ledge_walk_transition_left_90_inside"
    AnimNameLedgeWalkTransitionLeftOutside="player_ledge_walk_transition_left_90_outside"
    AnimNameLedgeWalkTransitionRightInside="player_ledge_walk_transition_right_90_inside"
    AnimNameLedgeWalkTransitionRightOutside="player_ledge_walk_transition_right_90_outside"
    AnimNameExitLedgeWalkRightInside="player_ledge_walk_exit_right_inside_left"
    AnimNameExitLedgeWalkLeftInside="player_ledge_walk_exit_left_inside_right"
    AnimNameExitLedgeWalkRightOutside="player_ledge_walk_exit_right_outside_right"
    AnimNameExitLedgeWalkLeftOutside="player_ledge_walk_exit_left_outside_left"
    AnimNameJumpFromLedgeWalk="player_jump_from_ledge_walk"
    AnimNameStepOffFromLedgeWalk="player_ledge_walk_stepoff"
    AnimNameEnterSqueezeLeft="player_squeeze_enter_left"
    AnimNameEnterSqueezeRight="player_squeeze_enter_right"
    AnimNameExitSqueezeLeft="player_squeeze_exit_left"
    AnimNameExitSqueezeRight="player_squeeze_exit_right"
    AnimNameAutomaticSqueeze="player_squeeze_through"
    AnimNameEnterLadderGroundStraight="player_ladder_grab_straight"
    AnimNameEnterLadderGround45Left="player_ladder_grab_45l"
    AnimNameEnterLadderGround45Right="player_ladder_grab_45r"
    AnimNameExitLadderOnTopLH="player_ladder_exit_lh"
    AnimNameExitLadderOnTopRH="player_ladder_exit_rh"
    AnimNamePickupObject_h40v70="player_object_pickup_h40v70"
    AnimNamePickupObject_h40v140="player_object_pickup_h40v140"
    AnimNamePickupObject_h85v70="player_object_pickup_h85v70"
    AnimNamePickupObject_h85v140="player_object_pickup_h85v140"
    AnimNamePickupObject_h62v105="player_object_pickup_h62v105"
    AnimNamePickupObjectCrouched_h30vm10="player_crouch_object_pickup_h30v-10"
    AnimNamePickupObjectCrouched_h60vm10="player_crouch_object_pickup_h60v-10"
    AnimNamePickupObjectCrouched_h45v35="player_crouch_object_pickup_h45v35"
    AnimNamePickupObjectCrouched_h30v60="player_crouch_object_pickup_h30v60"
    AnimNamePickupObjectCrouched_h60v60="player_crouch_object_pickup_h60v60"
    AnimNamePickupDoc_h40v70="player_doc_pickup_h40v70"
    AnimNamePickupDoc_h40v140="player_doc_pickup_h40v140"
    AnimNamePickupDoc_h85v70="player_doc_pickup_h85v70"
    AnimNamePickupDoc_h85v140="player_doc_pickup_h85v140"
    AnimNamePickupDoc_h62v105="player_doc_pickup_h62v105"
    AnimNamePickupDocCrouched_h30vm10="player_crouch_doc_pickup_h30v-10"
    AnimNamePickupDocCrouched_h60vm10="player_crouch_doc_pickup_h60v-10"
    AnimNamePickupDocCrouched_h45v35="player_crouch_doc_pickup_h45v35"
    AnimNamePickupDocCrouched_h30v60="player_crouch_doc_pickup_h30v60"
    AnimNamePickupDocCrouched_h60v60="player_crouch_doc_pickup_h60v60"
    AnimNamePutdownObject="player_object_putdown"
    AnimNameCloseDoorLeftFront="player_door_close_left_front"
    AnimNameCloseDoorLeftSide="player_door_close_left_side"
    AnimNameCloseDoorLeftBack="player_door_close_left_back"
    AnimNameCloseDoorLeftInside="player_door_close_inside_left"
    AnimNameCloseDoorRightFront="player_door_close_right_front"
    AnimNameCloseDoorRightSide="player_door_close_right_side"
    AnimNameCloseDoorRightBack="player_door_close_right_back"
    AnimNameCloseDoorRightInside="player_door_close_inside_right"
    AnimNameCloseDoorLeftFrontSlow="player_door_close_left_front_slow"
    AnimNameCloseDoorLeftSideSlow="player_door_close_left_side_slow"
    AnimNameCloseDoorLeftBackSlow="player_door_close_left_back_slow"
    AnimNameCloseDoorLeftInsideSlow="player_door_close_inside_left_slow"
    AnimNameCloseDoorRightFrontSlow="player_door_close_right_front_slow"
    AnimNameCloseDoorRightSideSlow="player_door_close_right_side_slow"
    AnimNameCloseDoorRightBackSlow="player_door_close_right_back_slow"
    AnimNameCloseDoorRightInsideSlow="player_door_close_inside_right_slow"
    AnimNameDoorOpenPullLeft="player_door_open_pull_left"
    AnimNameDoorOpenPullRight="player_door_open_pull_right"
    AnimNameDoorOpenPushLeft="player_door_open_push_left"
    AnimNameDoorOpenPushRight="player_door_open_push_right"
    AnimNameDoorRunThroughLeft="player_run_door_open_left"
    AnimNameDoorRunThroughRight="player_run_door_open_right"
    AnimNameDoorOpenInsidePushLeft="player_door_open_inside_left"
    AnimNameDoorOpenInsidePushRight="player_door_open_inside_right"
    AnimNameDoorAccessLeft="player_door_access_left"
    AnimNameDoorAccessRight="player_door_access_right"
    AnimNameDoorAccessLeftPull15="player_door_access_left_pull_15"
    AnimNameDoorAccessRightPull15="player_door_access_right_pull_15"
    AnimNameDoorAccessLeftPush15="player_door_access_left_push_15"
    AnimNameDoorAccessRightPush15="player_door_access_right_push_15"
    AnimNameDoorLockedLeft="player_door_locked_left"
    AnimNameDoorLockedRight="player_door_locked_right"
    AnimNameLockerOpenStraight="player_locker_open_straight"
    AnimNameLockerOpen45Left="player_locker_open_left_45"
    AnimNameLockerOpen45Right="player_locker_open_right_45"
    AnimNameHideInLocker="player_locker_hide"
    AnimNameGrabFromSqueezeLeftFacing="player_squeeze_fail_left_front"
    AnimNameGrabFromSqueezeLeftBack="player_squeeze_fail_left_back"
    AnimNameGrabFromSqueezeRightFacing="player_squeeze_fail_right_front"
    AnimNameGrabFromSqueezeRightBack="player_squeeze_fail_right_back"
    AnimNameGrabFromSqueezePhase1Right0="player_squeeze_fail_right_phase1"
    AnimNameGrabFromSqueezePhase1Right90="player_squeeze_fail_right_phase1_90"
    AnimNameGrabFromSqueezePhase1Right180="player_squeeze_fail_right_phase1_180"
    AnimNameGrabFromSqueezePhase1Left0="player_squeeze_fail_left_phase1"
    AnimNameGrabFromSqueezePhase1Left90="player_squeeze_fail_left_phase1_90"
    AnimNameGrabFromSqueezePhase1Left180="player_squeeze_fail_left_phase1_180"
    AnimNameEnterBedLeft="player_enter_bed_left"
    AnimNameEnterBedRight="player_enter_bed_right"
    AnimNameEnterBedLeftFromStand="player_enter_bed_left_stand"
    AnimNameEnterBedRightFromStand="player_enter_bed_right_stand"
    AnimNameExitBedLeft="player_exit_bed_left"
    AnimNameExitBedRight="player_exit_bed_right"
    AnimNameExitBedLeftToCrouch="player_exit_bed_left_crouch"
    AnimNameExitBedRightToCrouch="player_exit_bed_right_crouch"
    AnimNameEnterPushObjectLeft="player_push_object_enter_left"
    AnimNameEnterPushObjectRight="player_push_object_enter_right"
    AnimNameExitPushObjectLeft="player_push_object_exit_left"
    AnimNameExitPushObjectRight="player_push_object_exit_right"
    AnimNameRaiseCamcorder="player_camcorder_raise"
    AnimNameLowerCamcorder="player_camcorder_lower"
    AnimNameRaiseCamcorderBed="player_bed_camcorder_raise"
    AnimNameLowerCamcorderBed="player_bed_camcorder_lower"
    AnimNameRaiseCamcorderCrouched="player_crouch_camcorder_raise"
    AnimNameLowerCamcorderCrouched="player_crouch_camcorder_lower"
    AnimNameReloadBatteries="player_camcorder_reload"
    AnimNameReloadBatteriesInactive="player_camcorder_reload_inactive"
    AnimNameReloadBatteriesCrouched="player_crouch_camcorder_reload"
    AnimNameReloadBatteriesCrouchedInactive="player_crouch_camcorder_reload_inactive"
    AnimNameReloadBatteriesBed="player_bed_camcorder_reload"
    AnimNameReloadBatteriesBedInactive="player_bed_camcorder_reload_inactive"
    AnimNameReloadBatteriesSqueeze="player_squeeze_camera_reload"
    AnimNameReloadBatteriesSqueezeInactive="player_squeeze_camera_reload_inactive"
    AnimNameGrabNormal="player_grab"
    AnimNameGrabNormalLeft90="player_grab_left_90"
    AnimNameGrabNormalLeft180="player_grab_left_180"
    AnimNameGrabNormalRight90="player_grab_right_90"
    AnimNameGrabNormalRight180="player_grab_right_180"
    AnimNameGrabCrouched="player_crouch_grab"
    AnimNameGrabCrouchedLeft90="player_crouch_grab_left_90"
    AnimNameGrabCrouchedLeft180="player_crouch_grab_left_180"
    AnimNameGrabCrouchedRight90="player_crouch_grab_right_90"
    AnimNameGrabCrouchedRight180="player_crouch_grab_right_180"
    AnimNameGrabUnder="player_grab_reach_under"
    AnimNameGrabUnderCCW="player_grab_reach_under_ccw"
    AnimNameGrabUnderLeft90="player_grab_reach_under_left_90"
    AnimNameGrabUnderLeft180="player_grab_reach_under_left_180"
    AnimNameGrabUnderRight90="player_grab_reach_under_right_90"
    AnimNameGrabUnderRight180="player_grab_reach_under_right_180"
    AnimNameGrabFromBedLeft="player_grab_bed_left"
    AnimNameGrabFromBedRight="player_grab_bed_right"
    AnimNameGrabFromLocker="player_locker_grab"
    AnimNameThrown="player_grab_throw"
    AnimNameThrownLeft90="player_grab_throw_left_90"
    AnimNameThrownLeft180="player_grab_throw_left_180"
    AnimNameThrownRight90="player_grab_throw_right_90"
    AnimNameThrownRight180="player_grab_throw_right_180"
    AnimNameHitReactionFwd="player_hit_forward"
    AnimNameHitReactionBwd="player_hit_backward"
    AnimNameHitReactionLeft="player_hit_left"
    AnimNameHitReactionRight="player_hit_right"
    AnimNameHitReactionCrouchedFwd="player_crouch_hit_forward"
    AnimNameHitReactionCrouchedBwd="player_crouch_hit_backward"
    AnimNameHitReactionCrouchedLeft="player_crouch_hit_left"
    AnimNameHitReactionCrouchedRight="player_crouch_hit_right"
    AnimNameWallContactLeftHard="player_wall_contact_from_left_h"
    AnimNameWallContactLeftSoft="player_wall_contact_from_left_s"
    AnimNameWallContactRightHard="player_wall_contact_from_right_h"
    AnimNameWallContactRightSoft="player_wall_contact_from_right_s"
    AnimNameEnterCornerPeekLeftHard="player_wall_to_peek_from_left_h"
    AnimNameEnterCornerPeekLeftSoft="player_wall_to_peek_from_left_s"
    AnimNameEnterCornerPeekRightHard="player_wall_to_peek_from_right_h"
    AnimNameEnterCornerPeekRightSoft="player_wall_to_peek_from_right_s"
    AnimNameExitCornerPeekLeftHard="player_wall_leave_peek_from_left_h"
    AnimNameExitCornerPeekLeftSoft="player_wall_leave_peek_from_left_s"
    AnimNameExitCornerPeekRightHard="player_wall_leave_peek_from_right_h"
    AnimNameExitCornerPeekRightSoft="player_wall_leave_peek_from_right_s"
    AnimNameExitCornerPeekForwardLeftHard="player_wall_exit_from_left_h"
    AnimNameExitCornerPeekForwardLeftSoft="player_wall_exit_from_left_s"
    AnimNameExitCornerPeekForwardRightHard="player_wall_exit_from_right_h"
    AnimNameExitCornerPeekForwardRightSoft="player_wall_exit_from_right_s"
    AnimNameCornerTransitionFromLeft="player_wall_transition_from_left"
    AnimNameCornerTransitionFromRight="player_wall_transition_from_right"
    AnimNameGenericGrabFromBedLeft="player_generic_grab_bed_left"
    AnimNameGenericGrabFromBedRight="player_generic_grab_bed_right"
    AnimNameGenericGrabFromLocker="player_generic_locker_grab"
    AnimNameGenericGrabUnder="player_generic_grab_reach_under"
    AnimNameGenericGrabUnderLeft90="player_generic_grab_reach_under_left_90"
    AnimNameGenericGrabUnderLeft180="player_generic_grab_reach_under_left_180"
    AnimNameGenericGrabUnderRight90="player_generic_grab_reach_under_right_90"
    AnimNameGenericGrabUnderRight180="player_generic_grab_reach_under_right_180"
    AnimNamePushawayLeft="player_pushaway_left"
    AnimNamePushawayRight="player_pushaway_right"
    AnimNameGenericDeath="player_stand_death"
    AnimNameFatalityBackstabBack="player_fatality_backstab_back"
    AnimNameFatalityBackstabLeft="player_fatality_backstab_left"
    AnimNameFatalityBackstabRight="player_fatality_backstab_right"
    AnimNameFatalityChokeFront="player_fatality_choke_front"
    AnimNameFatalityChokeLeft="player_fatality_choke_left"
    AnimNameFatalityChokeRight="player_fatality_choke_right"
    AnimNameFatalityClubBack="player_fatality_clubbin_back"
    AnimNameFatalityClubFront="player_fatality_clubbin_front"
    AnimNameFatalityClubLeft="player_fatality_clubbin_left"
    AnimNameFatalityClubRight="player_fatality_clubbin_right"
    AnimNameFatalityStabChopFront="player_fatality_stabbychop_front"
    AnimNameFatalityStabChopLeft="player_fatality_stabbychop_left"
    AnimNameFatalityStabChopRight="player_fatality_stabbychop_right"
    AnimNameFatalityXplodeBack="player_fatality_xplod_back"
    AnimNameFatalityXplodeFront="player_fatality_xplod_forward"
    AnimNameFatalityXplodeLeft="player_fatality_xplod_left"
    AnimNameFatalityXplodeRight="player_fatality_xplod_right"
    AnimNameFatalityLocker="player_fatality_swarm_locker"
    AnimNameFatalitySoldier="player_grab_fatality"
    AnimNameFatalityGroom="player_grab_fatality_groom"
    ObstacleMinZWalking=50.0000000
    ObstacleMaxZWalking=245.0000000
    ObstacleMaxZFalling=50.0000000
    MinCosAngleToObstacle=0.7070000
    MaxLedgeCosAngle=0.7070000
    MinWidthForClimbWalking=75.0000000
    MinWidthForClimbRunning=100.0000000
    MinWidthForClimbUpWall=45.0000000
    MinWidthForSlide=75.0000000
    MaxWidthForSlide=175.0000000
    MinHeightForSlide=85.0000000
    MaxHeightForSlide=130.0000000
    StepUpAndLandInteractDist=40.0000000
    JumpOverInteractDistWalking=150.0000000
    JumpOverInteractDistRunning=300.0000000
    JumpOverInteractDistFalling=50.0000000
    JumpOverMinObstacleZ=50.0000000
    JumpOverExpectedDistWalking=40.0000000
    JumpOverExpectedHeightWalking=100.0000000
    JumpOverExpectedDistRunning=100.0000000
    JumpOverExpectedHeightRunning=100.0000000
    JumpOverAndGrabLedgeInteractDistWalking=150.0000000
    JumpOverAndGrabLedgeInteractDistRunning=300.0000000
    JumpOverAndGrabLedgeInteractDistFalling=50.0000000
    JumpOverAndGrabLedgeExpectedDist=30.0000000
    JumpOverAndGrabLedgeExpectedHeightFromLedge=100.0000000
    SlideOverInteractDistMin=50.0000000
    SlideOverInteractDistMax=300.0000000
    SlideOverExpectedDist=117.7000000
    SlideOverExpectedHeight=85.0000000
    ClimbUpInteractDistWalking=150.0000000
    ClimbUpInteractDistRunning=300.0000000
    ClimbUpInteractDistFalling=50.0000000
    ClimbUpWallInteractHeightMin=145.0000000
    ClimbUpExpectedDistWalking=44.4800000
    ClimbUpExpectedHeightWalking=85.0000000
    ClimbUpExpectedDistRunning=75.0000000
    ClimbUpExpectedHeightRunning=85.0000000
    ClimbUpWallExpectedDist=40.0000000
    ClimbUpWallExpectedHeightMin=150.0000000
    ClimbUpWallExpectedHeightMax=200.0000000
    ClimbOverWallExpectedDist=40.0000000
    ClimbOverWallExpectedHeight=200.0000000
    ClimbUpToCrouchExpectedDist=42.0000000
    ClimbUpToCrouchExpectedHeight=160.0000000
    ClimbUpToCrouchMinHeight=145.0000000
    GrabLedgeInteractDistWalking=150.0000000
    GrabLedgeInteractDistRunning=300.0000000
    GrabLedgeMinHeightOnGround=205.0000000
    GrabLedgeMaxHeightOnGround=325.0000000
    GrabLedgeMinFloorClearance=200.0000000
    GrabLedgeFromJumpOverMinFloorClearance=240.0000000
    GrabLedgeMinHeightInAir=150.0000000
    GrabLedgeMaxHeightInAir=250.0000000
    GrabLedgeInteractDistGoingDown=70.0000000
    GrabLedgeMinHeightInAirGoingDown=130.0000000
    GrabLedgeMaxHeightInAirGoingDown=200.0000000
    GrabLedgeFromGroundExpectedHeight=192.5000000
    GrabLedgeFromAirExpectedHeight=75.0000000
    GrabAndClimbInteractDist=70.0000000
    GrabAndClimbExpectedDistFwd=40.0000000
    GrabAndClimbExpectedDistHeight=115.6000000
    GrabAndClimbMinHeight=110.0000000
    GrabAndClimbMaxHeight=130.0000000
    LedgeHangDistToWall=45.0000000
    LedgeHangHeightToLedge=107.5000000
    LedgeHangTransitionInteractDist=40.0000000
    LedgeHangTransitionInsideExpectedDist=46.2500000
    LedgeHangTransitionOutsideExpectedDist=39.0000000
    LedgeHangClimbOverMaxLedgeWidth=85.0000000
    LedgeHangClimbOverMinHeightClearance=25.0000000
    LedgeHangClimbOverFullHeightClearance=100.0000000
    LedgeHangClimbUpMinFwdClearance=40.0000000
    LedgeWalkTransitionInteractDistInside=46.5000000
    LedgeWalkTransitionInteractDistOutside=66.2000000
    LedgeWalkTransitionInteractDistExit=46.5000000
    LedgeWalkEnterExpectedInsidePerpSideDist=33.1800000
    LedgeWalkEnterExpectedOutsidePerpSideDist=36.5100000
    LedgeWalkEnterExpectedInsidePrlSideDist=7.5000000
    LedgeWalkEnterExpectedOutsidePrlSideDist=33.1800000
    LedgeWalkEnterExpectedInsidePerpFwdDist=18.9000000
    LedgeWalkEnterExpectedOutsidePerpFwdDist=56.9800000
    LedgeWalkEnterExpectedInsidePrlFwdDist=56.9800000
    LedgeWalkEnterExpectedOutsidePrlFwdDist=47.9100000
    LedgeWalkTransitionExpectedDistInside=6.1600000
    LedgeWalkTransitionExpectedDistOutside=66.1600000
    LedgeWalkDistFromEdge=16.0500000
    LedgeWalkMaxWallDist=35.0000000
    LedgeWalkMinDrop=25.0000000
    SqueezeInteractDist=80.0000000
    SqueezeEnterExpectedDistFwd=40.0000000
    SqueezeExitExpectedDistFwd=37.0000000
    EnterLockerInteractDistance=120.0000000
    LadderEnterFromGroundInteractDist=100.0000000
    LadderEnterFromAboveInteractDist=65.0000000
    LadderGrabDist=75.0000000
    LadderEnterFromGroundDeltaZ=18.3000000
    LadderBarSpacing=25.0000000
    LadderRootHeightOffsetFromBar=17.0000000
    LadderEnterFromAboveExpectedDist=37.6000000
    LadderDistFwd=52.5000000
    LadderExitOnTopInteractDist=183.0000000
    LadderExitOnGroundInteractDist=10.0000000
    LadderMaxHeightForDrop=250.0000000
    PickupObjectExpectedDist=60.0000000
    PickupObjectInteractDistMinHorz=15.0000000
    PickupObjectInteractDistMaxHorz=100.0000000
    PickupObjectInteractDistMinVertStanding=60.0000000
    PickupObjectInteractDistMaxVertStanding=160.0000000
    PickupObjectInteractDistMinVertCrouched=-10.0000000
    PickupObjectInteractDistMaxVertCrouched=60.0000000
    DoorOpenInteractionDist=200.0000000
    DoorOpenExpectedFwdDist=53.2000000
    DoorOpenExpectedSideDist=44.0000000
    DoorOpenInsideExpectedDistFwd=40.0000000
    DoorRunThroughInteractDist=120.0000000
    DoorRunThroughExpectedDist=100.0000000
    DoorInteractiveOpenMaxAngle=90.0000000
    DoorMaxAngleForInteractiveOpen=16.0000000
    DoorCloseInteractionDist=200.0000000
    DoorCloseExpectedDistFwd=67.4000000
    LockerOpenStraightExpectedDistSide=28.5000000
    LockerOpenLeftExpectedDistSide=85.3000000
    LockerOpenRightExpectedDistSide=-28.5000000
    LockerOpenExpectedDistFwd=63.9000000
    LockerEnterExpectedDistSide=28.5000000
    LockerEnterExpectedDistFwd=63.9000000
    GrabFromSqueezeMaxDistance=100.0000000
    GrabFromSqueezeExpectedDistance=75.0000000
    BedInteractDistance=180.0000000
    BedEnterExpectedFwdDist=43.1000000
    BedEnterExpectedSideDist=105.0000000
    PushableInteractDist=150.0000000
    PushableInteractMinLookCosAngle=0.7100000
    PushableExpectedDistFromEdge=35.0000000
    PushableExpectedSideOffset=10.0000000
    PushFromLedgeAnimatedExpectedDist=20.0000000
    PushFromLedgeAnimatedInteractDist=20.0000000
    PushFromLedgeAnimatedMinHeight=120.0000000
    PushFromLedgeProceduralInteractDist=5.0000000
    PeekingEnterInteractDistFromWall=120.0000000
    PeekingEnterInteractDistFromEdgeMin=5.0000000
    PeekingEnterInteractDistFromEdgeMax=125.0000000
    PeekingEnterExpectedDistFromWall=35.0000000
    PeekingEnterExpectedDistFromEdgeLeft=30.0000000
    PeekingEnterExpectedDistFromEdgeRight=24.0000000
    ImpactVelThresholdForBigLanding=1125.0000000
    ImpactVelThresholdForSmallLanding=350.0000000
    ImpactVelThresholdForSpeedPenalty=700.0000000
    MinEyeDistToWall=15.0000000
    ForwardJumpSpeedThreshold=100.0000000
    MaxGrabLedgeAdjustment=125.0000000
    MaxSpeedPenaltyPctForInjuries=0.1000000
    DefaultLeftHandJointTargetRotation=(X=100.0000000,Y=-100.0000000,Z=130.0000000)
    CornerPeekJointTargetPosLeft=(X=100.0000000,Y=-30.0000000,Z=150.0000000)
    CornerPeekJointTargetPosRight=(X=100.0000000,Y=-30.0000000,Z=50.0000000)
    SpecialMoveParams[1]=(GP=(MaxPitchWS=75.0000000,Physics=EPhysics.PHYS_Walking),bAlwaysInterruptible=true,PlayerInputEnabled=true,KeepLocomotionMode=true)
    SpecialMoveParams[2]=(GP=(MaxPitchWS=75.0000000,Physics=EPhysics.PHYS_Walking),bAlwaysInterruptible=true,PlayerInputEnabled=true,KeepLocomotionMode=true)
    SpecialMoveParams[3]=(GP=(RMM=ERootMotionMode.RMM_Accel,MinPitchWS=-55.0000000),AnimName="player_jump_on_spot",PlayerInputEnabled=true)
    SpecialMoveParams[4]=(GP=(CameraMode=CameraRotationMode.CRM_Limited,MinPitchCS=0.0000000,MaxPitchCS=0.0000000))
    SpecialMoveParams[5]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinPitchCS=-30.0000000,MaxPitchCS=30.0000000,CollisionHeight=37.5000000,CollisionRadius=15.0000000),bExitOnBlendOut=true,bPlayAnimWhenPositioned=true,bCollisionChangeOnTrigger=true,AdjustPosition=true,AdjustOrientation=true,bUsePawnVelocityForPositionning=true,PositionningLinearVelocity=250.0000000)
    SpecialMoveParams[6]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_FullyAnimated,DisableCollisions=true,CollisionHeight=37.5000000,CollisionRadius=15.0000000,BothHandsNeeded=true),NextLocomotionMode=ELocomotionMode.LM_LedgeHang,AdjustPosition=true,AdjustOrientation=true)
    SpecialMoveParams[7]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinPitchCS=0.0000000,MaxPitchCS=30.0000000,CollisionHeight=37.5000000),bExitOnBlendOut=true,bPlayAnimWhenPositioned=true,bCollisionChangeOnTrigger=true,AdjustPosition=true,bUsePawnVelocityForPositionning=true,PositionningLinearVelocity=250.0000000)
    SpecialMoveParams[8]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-40.0000000,MaxYaw=40.0000000,MinPitchCS=-30.0000000,MaxPitchCS=30.0000000,CollisionHeight=27.5000000),bExitOnBlendOut=true,bPlayAnimWhenPositioned=true,bCollisionChangeOnTrigger=true,AdjustPosition=true,AdjustOrientation=true,bUsePawnVelocityForPositionning=true,PositionningLinearVelocity=250.0000000)
    SpecialMoveParams[9]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-40.0000000,MaxYaw=40.0000000,MinPitchCS=-30.0000000,MaxPitchCS=60.0000000,CollisionHeight=27.5000000,BothHandsNeeded=true),bExitOnBlendOut=true,bPlayAnimWhenPositioned=true,bCollisionChangeOnTrigger=true,AdjustPosition=true,AdjustOrientation=true,bUsePawnVelocityForPositionning=true,PositionningLinearVelocity=250.0000000)
    SpecialMoveParams[10]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinPitchCS=-30.0000000,MaxPitchCS=30.0000000,CollisionHeight=37.5000000,CollisionRadius=15.0000000,BothHandsNeeded=true),bExitOnBlendOut=true,bPlayAnimWhenPositioned=true,AdjustPosition=true,AdjustOrientation=true,bUsePawnVelocityForPositionning=true,PositionningLinearVelocity=250.0000000)
    SpecialMoveParams[11]=(bNoAnim=true)
    SpecialMoveParams[12]=(GP=(CameraMode=CameraRotationMode.CRM_Limited),NextLocomotionMode=ELocomotionMode.LM_LookBack,bNoAnim=true,PlayerInputEnabled=true)
    SpecialMoveParams[13]=(GP=(CameraMode=CameraRotationMode.CRM_Limited),bNoAnim=true,PlayerInputEnabled=true)
    SpecialMoveParams[14]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_FullyAnimated,DisableCollisions=true,CollisionHeight=15.0000000,CollisionRadius=15.0000000,BothHandsNeeded=true),NextLocomotionMode=ELocomotionMode.LM_LedgeHang,bPlayAnimWhenPositioned=true,bInterruptibleAfterTrigger=true,AdjustPosition=true,AdjustOrientation=true,bUsePawnVelocityForPositionning=true)
    SpecialMoveParams[15]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_FullyAnimated,CollisionHeight=15.0000000,CollisionRadius=15.0000000,BothHandsNeeded=true),NextLocomotionMode=ELocomotionMode.LM_LedgeHang,bInterruptibleAfterTrigger=true,AdjustPosition=true,AdjustOrientation=true)
    SpecialMoveParams[16]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-60.0000000,MaxYaw=60.0000000,MinPitchWS=-10.0000000,MaxPitchWS=50.0000000,BothHandsNeeded=true),NextLocomotionMode=ELocomotionMode.LM_LedgeHang,AdjustPosition=true)
    SpecialMoveParams[17]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinPitchCS=0.0000000,MaxPitchCS=0.0000000,CollisionHeight=12.0000000,CollisionRadius=15.0000000,BothHandsNeeded=true),bExitOnBlendOut=true,AdjustPosition=true)
    SpecialMoveParams[18]=(GP=(Physics=EPhysics.PHYS_Falling,BothHandsNeeded=true),NextLocomotionMode=ELocomotionMode.LM_Fall,AnimName="player_ledge_walk_stepoff",bExitOnBlendOut=true)
    SpecialMoveParams[19]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_FullyAnimated,CollisionRadius=15.0000000,BothHandsNeeded=true),bExitOnBlendOut=true,AdjustPosition=true,AdjustOrientation=true)
    SpecialMoveParams[20]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-30.0000000,MaxYaw=30.0000000,MinPitchWS=-60.0000000,MaxPitchWS=60.0000000,CollisionRadius=5.0000000),NextLocomotionMode=ELocomotionMode.LM_LedgeWalk,AdjustPosition=true,AdjustOrientation=true)
    SpecialMoveParams[21]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-20.0000000,MaxYaw=20.0000000,MinPitchWS=-60.0000000,MaxPitchWS=60.0000000,ViewLimitsApproachCoeff=0.9000000,CollisionRadius=5.0000000))
    SpecialMoveParams[22]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-40.0000000,MaxYaw=40.0000000,MinPitchWS=-50.0000000,MaxPitchWS=60.0000000),NextLocomotionMode=ELocomotionMode.LM_LedgeWalk,AdjustPosition=true)
    SpecialMoveParams[23]=(GP=(RMM=ERootMotionMode.RMM_Accel,Physics=EPhysics.PHYS_Falling),NextLocomotionMode=ELocomotionMode.LM_Fall,PlayerInputEnabled=true)
    SpecialMoveParams[24]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-15.0000000,MaxYaw=15.0000000,MinPitchWS=-30.0000000,MaxPitchWS=30.0000000,CollisionRadius=2.0000000),NextLocomotionMode=ELocomotionMode.LM_Squeeze,AdjustPosition=true,AdjustOrientation=true)
    SpecialMoveParams[25]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinPitchWS=-15.0000000,MaxPitchWS=45.0000000,CollisionRadius=2.0000000),bTargettedYawSmoothing=true,AdjustPosition=true,PositionningLinearVelocity=100.0000000)
    SpecialMoveParams[26]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-25.0000000,MaxYaw=25.0000000,MinPitchWS=-20.0000000,MaxPitchWS=30.0000000,CollisionRadius=2.0000000),AdjustPosition=true,AdjustOrientation=true)
    SpecialMoveParams[27]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-15.0000000,MaxYaw=15.0000000,MinPitchWS=0.0000000,MaxPitchWS=40.0000000,CollisionRadius=2.0000000),KeepLocomotionMode=true)
    SpecialMoveParams[28]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_FullyAnimated,CollisionRadius=15.0000000),NextLocomotionMode=ELocomotionMode.LM_Door,AdjustPosition=true,AdjustOrientation=true)
    SpecialMoveParams[29]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinPitchCS=0.0000000,MaxPitchCS=0.0000000),AdjustPosition=true,AdjustOrientation=true)
    SpecialMoveParams[30]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinPitchCS=0.0000000,MaxPitchCS=0.0000000),AdjustPosition=true,AdjustOrientation=true)
    SpecialMoveParams[31]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinPitchCS=0.0000000,MaxPitchCS=0.0000000),AdjustPosition=true,AdjustOrientation=true)
    SpecialMoveParams[32]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinPitchCS=0.0000000,MaxPitchCS=0.0000000),bExitOnBlendOut=true,AdjustPosition=true,AdjustOrientation=true)
    SpecialMoveParams[33]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinPitchCS=0.0000000,MaxPitchCS=0.0000000),AdjustPosition=true,AdjustOrientation=true)
    SpecialMoveParams[34]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinPitchCS=0.0000000,MaxPitchCS=0.0000000),bPlayAnimWhenPositioned=true,AdjustPosition=true,AdjustOrientation=true,PositionningLinearVelocity=450.0000000,PositionningAngularVelocity=400.0000000)
    SpecialMoveParams[35]=(GP=(CameraMode=CameraRotationMode.CRM_FullyAnimated,DisableCollisions=true,CollisionRadius=5.0000000),bNoAnim=true)
    SpecialMoveParams[36]=(GP=(CameraMode=CameraRotationMode.CRM_FullyAnimated,CollisionRadius=5.0000000),bNoAnim=true,PositionningLinearVelocity=500.0000000)
    SpecialMoveParams[37]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-15.0000000,MaxYaw=15.0000000,MinPitchCS=-15.0000000,MaxPitchCS=15.0000000,CollisionRadius=5.0000000),AdjustPosition=true,AdjustOrientation=true)
    SpecialMoveParams[38]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_FullyAnimated,DisableCollisions=true,CollisionRadius=5.0000000),NextLocomotionMode=ELocomotionMode.LM_Locker,AdjustPosition=true,AdjustOrientation=true)
    SpecialMoveParams[39]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_FullyAnimated,CollisionRadius=5.0000000),AnimName="player_locker_exit",AdjustPosition=true,AdjustOrientation=true)
    SpecialMoveParams[40]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_FullyAnimated,FOVOverride=110.0000000,DisableCollisions=true,CollisionHeight=5.0000000,CollisionRadius=20.0000000),NextLocomotionMode=ELocomotionMode.LM_Bed,bExitOnBlendOut=true,AdjustPosition=true,AdjustOrientation=true,PositionningLinearVelocity=100.0000000)
    SpecialMoveParams[41]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-5.0000000,MaxYaw=5.0000000,MinPitchCS=0.0000000,MaxPitchCS=0.0000000,DisableCollisions=true,CollisionHeight=5.0000000,CollisionRadius=20.0000000),AdjustPosition=true,AdjustOrientation=true,PositionningLinearVelocity=10.0000000)
    SpecialMoveParams[42]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-15.0000000,MaxYaw=15.0000000,MinPitchWS=-15.0000000,MaxPitchWS=15.0000000,CollisionHeight=5.0000000,CollisionRadius=20.0000000),KeepLocomotionMode=true)
    SpecialMoveParams[43]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-15.0000000,MaxYaw=15.0000000,MinPitchWS=10.0000000,MaxPitchWS=60.0000000,CollisionRadius=15.0000000,BothHandsNeeded=true),NextLocomotionMode=ELocomotionMode.LM_Ladder,AdjustPosition=true,AdjustOrientation=true)
    SpecialMoveParams[44]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_FullyAnimated,DisableCollisions=true,CollisionRadius=15.0000000,BothHandsNeeded=true),NextLocomotionMode=ELocomotionMode.LM_Ladder,AnimName="player_ladder_enter_above",AdjustPosition=true,AdjustOrientation=true)
    SpecialMoveParams[45]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-60.0000000,MaxYaw=60.0000000,MinPitchWS=-30.0000000,MaxPitchWS=30.0000000,CollisionRadius=15.0000000,BothHandsNeeded=true),bNoAnim=true,AdjustPosition=true,AdjustOrientation=true)
    SpecialMoveParams[46]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-15.0000000,MaxYaw=15.0000000,MinPitchWS=-10.0000000,MaxPitchWS=30.0000000,CollisionRadius=5.0000000,BothHandsNeeded=true))
    SpecialMoveParams[47]=(GP=(CollisionRadius=15.0000000,Physics=EPhysics.PHYS_Falling,BothHandsNeeded=true),NextLocomotionMode=ELocomotionMode.LM_Fall,bNoAnim=true)
    SpecialMoveParams[48]=(GP=(CameraMode=CameraRotationMode.CRM_FullyAnimated,MinYaw=-15.0000000,MaxYaw=15.0000000,MinPitchWS=10.0000000,MaxPitchWS=80.0000000,CollisionRadius=15.0000000,BothHandsNeeded=true),NextLocomotionMode=ELocomotionMode.LM_Ladder,AnimName="player_ladder_grab_from_air",AdjustPosition=true,AdjustOrientation=true)
    SpecialMoveParams[49]=(GP=(CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-15.0000000,MaxYaw=15.0000000,MinPitchCS=-15.0000000,MaxPitchCS=15.0000000,CollisionRadius=15.0000000),AdjustOrientation=true,PositionningAngularVelocity=60.0000000)
    SpecialMoveParams[50]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Locked,MinPitchCS=0.0000000,MaxPitchCS=0.0000000,CollisionRadius=15.0000000),KeepLocomotionMode=true,AdjustPosition=true,AdjustOrientation=true)
    SpecialMoveParams[51]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_FullyAnimated,BothHandsNeeded=true),NextLocomotionMode=ELocomotionMode.LM_Struggle,AdjustPosition=true,AdjustOrientation=true)
    SpecialMoveParams[52]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_FullyAnimated,BothHandsNeeded=true),bExitOnBlendOut=true)
    SpecialMoveParams[53]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_FullyAnimated,BothHandsNeeded=true))
    SpecialMoveParams[54]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-15.0000000,MaxYaw=15.0000000,MinPitchCS=-15.0000000,MaxPitchCS=15.0000000,CollisionRadius=15.0000000,BothHandsNeeded=true),NextLocomotionMode=ELocomotionMode.LM_Pushing,AdjustPosition=true,AdjustOrientation=true)
    SpecialMoveParams[55]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-30.0000000,MaxYaw=30.0000000,MinPitchCS=-30.0000000,MaxPitchCS=30.0000000,BothHandsNeeded=true),bExitOnBlendOut=true)
    SpecialMoveParams[56]=(GP=(RMM=ERootMotionMode.RMM_Accel,CollisionHeight=27.5000000),NextLocomotionMode=ELocomotionMode.LM_Fall,bNoAnim=true)
    SpecialMoveParams[57]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-30.0000000,MaxYaw=30.0000000,CollisionHeight=27.5000000),NextLocomotionMode=ELocomotionMode.LM_Fall,AnimName="player_crouch_over_ledge",bExitOnBlendOut=true,AdjustPosition=true,AdjustOrientation=true)
    SpecialMoveParams[58]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-15.0000000,MaxYaw=15.0000000,MinPitchCS=-15.0000000,MaxPitchCS=15.0000000),NextLocomotionMode=ELocomotionMode.LM_ContextualLean,bNoAnim=true,AdjustPosition=true,AdjustOrientation=true,PositionningLinearVelocity=125.0000000)
    SpecialMoveParams[59]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-15.0000000,MaxYaw=15.0000000,MinPitchCS=-15.0000000,MaxPitchCS=15.0000000),bNoAnim=true)
    SpecialMoveParams[60]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinYaw=-15.0000000,MaxYaw=15.0000000,MinPitchCS=-15.0000000,MaxPitchCS=15.0000000),bExitOnBlendOut=true)
    SpecialMoveParams[61]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinPitchCS=-15.0000000,MaxPitchCS=15.0000000,CollisionRadius=5.0000000),NextLocomotionMode=ELocomotionMode.LM_ContextualLean)
    SpecialMoveParams[62]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinPitchCS=0.0000000,MaxPitchCS=0.0000000,IgnorePawnCollisions=true),NextLocomotionMode=ELocomotionMode.LM_Grabbed,AdjustPosition=true,AdjustOrientation=true)
    SpecialMoveParams[63]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_FullyAnimated,IgnorePawnCollisions=true,CollisionRadius=5.0000000),NextLocomotionMode=ELocomotionMode.LM_Grabbed,AdjustPosition=true,AdjustOrientation=true)
    SpecialMoveParams[64]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_FullyAnimated,IgnorePawnCollisions=true))
    SpecialMoveParams[65]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_FullyAnimated,DisableCollisions=true))
    SpecialMoveParams[66]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_FullyAnimated,IgnorePawnCollisions=true,CollisionHeight=35.0000000,CollisionRadius=5.0000000),AdjustPosition=true)
    SpecialMoveParams[67]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_Limited,MinPitchCS=0.0000000,MaxPitchCS=0.0000000,IgnorePawnCollisions=true,CollisionRadius=5.0000000))
    SpecialMoveParams[68]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_FullyAnimated),NextLocomotionMode=ELocomotionMode.LM_Cinematic)
    SpecialMoveParams[69]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_FullyAnimated,MinPitchWS=-90.0000000,MaxPitchWS=90.0000000),AdjustPosition=true,AdjustOrientation=true)
    SpecialMoveParams[70]=(GP=(RMM=ERootMotionMode.RMM_Accel,CameraMode=CameraRotationMode.CRM_FullyAnimated))
    // Reference: DynamicLightEnvironmentComponent'OLGame.Default__OLHero.MyLightEnvironment'
    // TemplateOwnerClass: none
    // TemplateOwnerName: 'MyLightEnvironment'
    // Archetype: DynamicLightEnvironmentComponent'OLGame.Default__OLPawn.MyLightEnvironment'
    begin object name="MyLightEnvironment"
    end object
    LightEnvironment=MyLightEnvironment
    HeadBoneName="Hero-Head"
    DefaultAirControl=0.0000000
    // Reference: AudioComponent'OLGame.Default__OLHero.AmbientSoundComponent'
    // TemplateOwnerClass: none
    // TemplateOwnerName: 'AmbientSoundComponent'
    // Archetype: AudioComponent'OLGame.Default__OLPawn.AmbientSoundComponent'
    begin object name="AmbientSoundComponent"
    end object
    PawnAmbientSound=AmbientSoundComponent
    MaxStepHeight=30.0000000
    MaxJumpHeight=110.0000000
    CrouchHeight=37.5000000
    AirControl=0.0000000
    CrouchedPct=1.0000000
    // Reference: SkeletalMeshComponent'OLGame.Default__OLHero.WPawnSkeletalMeshComponent'
    // TemplateOwnerClass: none
    // TemplateOwnerName: 'WPawnSkeletalMeshComponent'
    begin object name="WPawnSkeletalMeshComponent" class=Engine.SkeletalMeshComponent
        SkeletalMesh=SkeletalMesh'02_Player.Pawn.Miles_beheaded'
        AnimTreeTemplate=AnimTree'02_Behaviors.Player.Player_AnimTree'
        PhysicsAsset=PhysicsAsset'02_Player.Pawn.Player_Physics'
        AnimSets[0]=AnimSet'03_Hero.Hero-01_AS'
        AnimSets[1]=AnimSet'03_OL_ScriptedEvents.Hero_SE'
        MinDistFactorForKinematicUpdate=0.2000000
        bIgnoreControllersWhenNotRendered=true
        bHasPhysicsAssetInstance=true
        bPerBoneMotionBlur=true
        bOverrideAttachmentOwnerVisibility=true
        bChartDistanceFactor=true
        bCacheAnimSequenceNodes=false
        ReplacementPrimitive=none
        LightEnvironment=DynamicLightEnvironmentComponent'OLGame.Default__OLHero.MyLightEnvironment'
        RBChannel=ERBCollisionChannel.RBCC_Pawn
        RBDominanceGroup=5
        bSelfShadowOnly=true
        bUseOnePassLightingOnTranslucency=true
        BlockRigidBody=true
        LightingChannels=(bInitialized=true,Dynamic=true,Skybox=true,Unnamed_1=true,Unnamed_2=true,Unnamed_3=true,Unnamed_4=true,Unnamed_5=true,Unnamed_6=true,Cinematic_1=true,Cinematic_2=true,Cinematic_3=true,Cinematic_4=true,Cinematic_5=true,Dynamic_1=true,Dynamic_2=true,Dynamic_3=true,Dynamic_4=true,Dynamic_5=true,Gameplay_1=true,Gameplay_2=true,Gameplay_3=true,Gameplay_4=true)
        RBCollideWithChannels=(Default=true,Pawn=true,GameplayPhysics=true,Untitled3=true,BlockingVolume=true)
    end object
    Mesh=WPawnSkeletalMeshComponent
    // Reference: CylinderComponent'OLGame.Default__OLHero.CollisionCylinder'
    // TemplateOwnerClass: none
    // TemplateOwnerName: 'CollisionCylinder'
    // Archetype: CylinderComponent'OLGame.Default__OLPawn.CollisionCylinder'
    begin object name="CollisionCylinder"
        ReplacementPrimitive=none
    end object
    CylinderComponent=CollisionCylinder
    ViewPitchMin=-13800.0000000
    ViewPitchMax=10000.0000000
    Components[0]=none
    Components[1]=CollisionCylinder
    Components[2]=none
    Components[3]=MyLightEnvironment
    Components[4]=AmbientSoundComponent
    Components[5]=WPawnSkeletalMeshComponent
    Components[6]=ShadowProxyComponent
    Components[7]=HeadMeshComp
    Components[8]=NVLightComponent
    Components[9]=NVLightNoBatteriesComponent
    Components[10]=DarkLightComponent
    Components[11]=CamcorderScreenLightComp
    Components[12]=RainEffectComponent
    // Reference: ParticleLightEnvironmentComponent'OLGame.Default__OLHero.FootstepsLightEnvironment'
    // TemplateOwnerClass: none
    // TemplateOwnerName: 'FootstepsLightEnvironment'
    begin object name="FootstepsLightEnvironment" class=Engine.ParticleLightEnvironmentComponent
        bUseBooleanEnvironmentShadowing=false
        bSynthesizeSHLight=true
        bForceNonCompositeDynamicLights=true
    end object
    Components[13]=FootstepsLightEnvironment
    CollisionComponent=CollisionCylinder
}