class OLPlayerController extends UDKPlayerController
    native
    config(Game)
    hidecategories(Navigation);

enum EPlayerInteractionType
{
    PIT_CSA,                        // 0
    PIT_PickupObject,               // 1
    PIT_BatteriesFull,              // 2
    PIT_EnterBed,                   // 3
    PIT_EnterLocker,                // 4
    PIT_ExitLocker,                 // 5
    PIT_OpenDoor,                   // 6
    PIT_OpenPartiallyOpenDoor,      // 7
    PIT_CloseDoor,                  // 8
    PIT_LockedDoor,                 // 9
    PIT_AutoCloseDoor,              // 10
    PIT_ClimbUpLedge,               // 11
    PIT_ReloadBatteries,            // 12
    PIT_Struggle,                   // 13
    PIT_PushObject,                 // 14
    PIT_MAX                         // 15
};

enum ZoomMovementType
{
    Zoom_Undefined,                 // 0
    Zoom_MovingLeft,                // 1
    Zoom_NotMoving,                 // 2
    Zoom_MovingRight,               // 3
    Zoom_MAX                        // 4
};

enum StruggleInputDirection
{
    SID_Undefined,                  // 0
    SID_Left,                       // 1
    SID_Right,                      // 2
    SID_MAX                         // 3
};

enum EAIMusicState
{
    EAIMS_None,                     // 0
    EAIMS_Patrol,                   // 1
    EAIMS_Investigate,              // 2
    EAIMS_Chase,                    // 3
    EAIMS_MAX                       // 4
};

enum EOutlastAchievement
{
    OA_000_StartedGenerator,        // 0
    OA_001_DrainedSewer,            // 1
    OA_002_StartedSprinklers,       // 2
    OA_003_FoundFemaleWardKey,      // 3
    OA_004_MilestoneCollectibles,   // 4
    OA_005_FinishedGame,            // 5
    OA_006_AllCollectibles,         // 6
    OA_007_FinishedNightmare,       // 7
    OA_008_TurnOffGas,              // 8
    OA_009_TurnOffPower,            // 9
    OA_010_FinishDLC,               // 10
    OA_011_FinishDLCInsane,         // 11
    OA_012_AllDLCDocs,              // 12
    OA_013_AllDLCRecordings,        // 13
    OA_MAX                          // 14
};

struct native DigitalInputs
{
    var bool bPerformedUseAction;
    var bool bPressedUseButton;
    var bool bReleasedUseButton;
    var bool bPressedToggleCamcorder;
    var bool bPressedToggleNightVision;
    var bool bPressedZoomIn;
    var bool bPressedZoomOut;
    var bool bPressedJump;
    var bool bPressedReloadBatteries;
    var bool bStartedActiveZoom;

    structdefaultproperties
    {
        bPerformedUseAction=false
        bPressedUseButton=false
        bReleasedUseButton=false
        bPressedToggleCamcorder=false
        bPressedToggleNightVision=false
        bPressedZoomIn=false
        bPressedZoomOut=false
        bPressedJump=false
        bPressedReloadBatteries=false
        bStartedActiveZoom=false
    }
};

struct native TouchZoomData
{
    var float bActive;
    var float SmoothedPosition;
    var OLPlayerController.ZoomMovementType CurrentDirection;
    var float LastPosition;
    var float LastInputTime;

    structdefaultproperties
    {
        bActive=0.0000000
        SmoothedPosition=0.0000000
        CurrentDirection=ZoomMovementType.Zoom_Undefined
        LastPosition=0.0000000
        LastInputTime=0.0000000
    }
};

struct native StruggleData
{
    var OLSeqAct_Struggle StruggleAct;
    var SkeletalMeshActor Enemy;
    var Vector RefLocation;
    var Vector RefDirection;
    var StruggleConfig Config;
    var OLAnimEnemyStruggle EnemyAnimNode;
    var bool bActiveStrugging;
    var bool bSucceeded;
    var float CycleStartedTime;
    var float NbShakes;
    var OLPlayerController.StruggleInputDirection CurrentInputDirection;
    var float TotalDeltas;
    var float LastMouseX;
    var float SmoothedDirection;
    var float SmoothedAnimPlayRate;

    structdefaultproperties
    {
        StruggleAct=none
        Enemy=none
        RefLocation=(X=0.0000000,Y=0.0000000,Z=0.0000000)
        RefDirection=(X=0.0000000,Y=0.0000000,Z=0.0000000)
        Config=(InitIdleAnimEnemy="None",EntryAnimPlayer="None",EntryAnimEnemy="None",CycleAnimPlayer="None",CycleAnimEnemy="None",ExitAnimPlayer="None",ExitAnimEnemy="None",KilledAnimPlayer="None",KillAnimEnemy="None",EntryPlayerBlendInTime=0.2500000,ExitPlayerBlendOutTime=0.2500000,CycleTime=3.0000000,bNoFail=false,MinRate=0.2500000,MaxRateStart=1.0000000,MaxRateEnd=3.0000000,SuccessPctForMinRate=0.5000000,SuccessPctForMaxRate=1.0000000,HeroAnimSets=none)
        EnemyAnimNode=none
        bActiveStrugging=false
        bSucceeded=false
        CycleStartedTime=0.0000000
        NbShakes=0.0000000
        CurrentInputDirection=StruggleInputDirection.SID_Undefined
        TotalDeltas=0.0000000
        LastMouseX=0.0000000
        SmoothedDirection=0.0000000
        SmoothedAnimPlayRate=0.0000000
    }
};

struct native CheckpointRecord
{
    var int CheckpointRecordVersion;
    var int NumBatteries;
    var name CurrentObjective;
    var array<name> CompletedObjectives;
    var array<name> CompletedRecordingMoments;
    var array<name> UnreadRecordingMoments;
    var array<name> ActivatedGameState;
    var array<name> CollectedDocuments;
    var array<name> UnreadDocuments;
    var array<Vector> CollectedBatteries;
    var bool bBatteryTutorialComplete;
    var bool bClimbUpTutorialComplete;
    var bool bDocumentTutorialComplete;
    var bool bFoundBySoldierWhileHidden;
    var bool bFoundBySurgeonWhileHidden;
    var float RecordingTimeSeconds;
    var int DifficultyMode;
    var float BatteryEnergy;

    structdefaultproperties
    {
        CheckpointRecordVersion=0
        NumBatteries=0
        CurrentObjective="None"
        CompletedObjectives=none
        CompletedRecordingMoments=none
        UnreadRecordingMoments=none
        ActivatedGameState=none
        CollectedDocuments=none
        UnreadDocuments=none
        CollectedBatteries=none
        bBatteryTutorialComplete=false
        bClimbUpTutorialComplete=false
        bDocumentTutorialComplete=false
        bFoundBySoldierWhileHidden=false
        bFoundBySurgeonWhileHidden=false
        RecordingTimeSeconds=0.0000000
        DifficultyMode=0
        BatteryEnergy=0.0000000
    }
};

struct native DeprecatedCheckpointRecord
{
    var int NumBatteries;
    var name CurrentObjective;
    var array<name> CompletedObjectives;
    var array<name> CompletedRecordingMoments;
    var array<name> UnreadRecordingMoments;
    var array<name> ActivatedGameState;
    var array<name> CollectedDocuments;
    var array<name> UnreadDocuments;
    var array<Vector> CollectedBatteries;
    var bool bBatteryTutorialComplete;
    var bool bClimbUpTutorialComplete;
    var bool bDocumentTutorialComplete;
    var bool bFoundBySoldierWhileHidden;
    var bool bFoundBySurgeonWhileHidden;
    var float RecordingTimeSeconds;

    structdefaultproperties
    {
        NumBatteries=0
        CurrentObjective="None"
        CompletedObjectives=none
        CompletedRecordingMoments=none
        UnreadRecordingMoments=none
        ActivatedGameState=none
        CollectedDocuments=none
        UnreadDocuments=none
        CollectedBatteries=none
        bBatteryTutorialComplete=false
        bClimbUpTutorialComplete=false
        bDocumentTutorialComplete=false
        bFoundBySoldierWhileHidden=false
        bFoundBySurgeonWhileHidden=false
        RecordingTimeSeconds=0.0000000
    }
};

var OLHero HeroPawn;
var OLHUD HUD;
var OLInventoryManager InventoryManager;
var OLTutorialManager TutorialManager;
var OLSoundEnvironmentManager SoundEnvManager;
var OLFXManager FXManager;
var OLSeqAct_SplashScreen ActiveSplashScreen;
var bool bFlushingStreaming;
var bool bHasCamcorder;
var bool bBlockedOnLoading;
var bool bShowingKismetControlledLoadingScreen;
var bool bShowingLoadingOverlay;
var bool bProfileSettingsUpdated;
var bool bValidDoorHold;
var bool bInvalidateLeanInput;
var bool bInvalidateReleasedUse;
var bool bToggleCrouch;
var bool bOverriddenMusic;
var bool bTravellingToCheckpoint;
var bool bTravelCheckPersistent;
var bool bForceLevelReset;
var bool bFoundBySoldierWhileHidden;
var bool bFoundBySurgeonWhileHidden;
var config bool bEnableShadowOptimisation;
var config bool bEnableLightOptimisation;
var bool bBehindView;
var bool bDebugFixedCam;
var bool bDebugFreeCam;
var bool bDebugGhost;
var bool bSlowDownFPS;
var name CurrentObjective;
var array<name> CompletedObjectives;
var int NumBatteries;
var int MaxNumBatteries;
var config int NrmMaxNumBatteries;
var config int HardMaxNumBatteries;
var config int NightmareMaxNumBatteries;
var config int DefaultNumBatteries;
var float GameOverActivatedTimestamp;
var array<OLPlayerController.EPlayerInteractionType> AvailableInteractions;
var string CSAPrompt;
var string PickupTargetName;
var OLProfileSettings ProfileSettings;
var DigitalInputs Inputs;
var input byte bLeanInputLeft;
var input byte bLeanInputRight;
var input byte bRunInput;
var input byte bUseButtonDown;
var OLPlayerController.EAIMusicState AIMusic;
var OLPlayerController.EAIMusicState OverriddenMusicState;
var input float PureMouseX;
var input float AnalogLeanInputLeft;
var input float AnalogLeanInputRight;
var int ZoomInput;
var float UsePressedTime;
var Vector LastPlayerInputIntent;
var TouchZoomData TouchZoom;
var LinearColor LightBarColor;
var float LightBarPulsePhase;
var array<name> CompletedRecordingMoments;
var array<name> UnreadRecordingMoments;
var OLRecordingMarker PendingRecordingMarker;
var float RecordingCompletedTime;
var transient StruggleData Struggle;
var config float StruggleInputThresholdForWin;
var config float StruggleShakesThresholdForWin;
var config float StruggleInputThresholdForWinNoFail;
var config float StruggleShakesThresholdForWinNoFail;
var float AIDistance;
var float OverriddenMusicDistance;
var float AIChaseMusicTimer;
var config float AIChaseMusicTimeDelay;
var const name MusicAIStateGroup;
var const name MusicAIStateNone;
var const name MusicAIStatePatrol;
var const name MusicAIStateInvestigate;
var const name MusicAIStateChase;
var const name LoadingStateGroup;
var const name LoadingStateOn;
var const name LoadingStateOff;
var const name AIDistanceRTPC;
var const AkEvent SndResetMixStates;
var int NumDeathsSinceLastCheckpoint;
var float StableLevelsTimestamp;
var int NumBatteriesAtLastCheckpoint;
var float BatteryEnergyAtLastCheckpoint;
var config name FirstSoldierFindableCheckpoint;
var config name FirstSurgeonFindableCheckpoint;
var int FindHiddenPlayerSkipCount;
var Vector LastLightOptimCamPos;
var array<name> LevelsResetAfterPlayerDeath;
var Vector DesiredLocation;
var float LastCameraTimeStamp;
var Class<Camera> MatineeCameraClass;
var Actor CalcViewActor;
var Vector CalcViewActorLocation;
var Rotator CalcViewActorRotation;
var Vector CalcViewLocation;
var Rotator CalcViewRotation;
var globalconfig float OnFootDefaultFOV;
var Rotator DebugCamRot;
var Vector DebugCamPos;
var float DebugFreeCamSpeed;
var float DebugFreeCamFOV;
var float SlowDownFactor;

// Export UOLPlayerController::execNativePlayerMove(FFrame&, void* const)
native function NativePlayerMove(float DeltaTime);

// Export UOLPlayerController::execGetGamma(FFrame&, void* const)
native function float GetGamma();

// Export UOLPlayerController::execSetGamma(FFrame&, void* const)
native function SetGamma(float GammaValue);

// Export UOLPlayerController::execSetVolume(FFrame&, void* const)
native function SetVolume(float VolumeLevel);

// Export UOLPlayerController::execShowLoadingOverlay(FFrame&, void* const)
native function ShowLoadingOverlay();

// Export UOLPlayerController::execHideLoadingOverlay(FFrame&, void* const)
native function HideLoadingOverlay();

simulated event PostBeginPlay()
{
    super(PlayerController).PostBeginPlay();
    // End:0x38
    if(__NFUN_119__(TutorialManager, none))
    {
        TutorialManager.Clear();
    }
    bProfileSettingsUpdated = true;
    UpdateDifficultyBasedValues();
    //return;    
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
    super(PlayerController).Possess(inPawn, bVehicleTransition);
    HeroPawn = OLHero(inPawn);
    bDuck = 0;
    //return;    
}

event UnPossess()
{
    HeroPawn = none;
    super(PlayerController).UnPossess();
    //return;    
}

function Reset()
{
    super(PlayerController).Reset();
    // End:0x31
    if(__NFUN_119__(PlayerCamera, none))
    {
        PlayerCamera.__NFUN_279__();
    }
    TutorialManager.Clear();
    //return;    
}

reliable client simulated function ClientRestart(Pawn NewPawn)
{
    super(PlayerController).ClientRestart(NewPawn);
    //return;    
}

event Destroyed()
{
    // End:0x2E
    if(__NFUN_119__(SoundEnvManager, none))
    {
        SoundEnvManager.Cleanup();
    }
    //return;    
}

function PlayerDied()
{
    __NFUN_165__(NumDeathsSinceLastCheckpoint);
    InventoryManager.ClearGameplayItems();
    InventoryManager.ClearUnsavedBatteries();
    CurrentObjective = 'None';
    PendingRecordingMarker = none;
    //return;    
}

// Export UOLPlayerController::execIsPlayerFindableWhileHidden(FFrame&, void* const)
native function bool IsPlayerFindableWhileHidden(OLEnemyPawn SearchingEnemy);

// Export UOLPlayerController::execSetPlayerFoundWhileHidden(FFrame&, void* const)
native function SetPlayerFoundWhileHidden(OLEnemyPawn SearchingEnemy);

simulated function bool PerformedUseAction()
{
    // End:0x0F
    if(super(PlayerController).PerformedUseAction())
    {
        return true;
    }
    Inputs.bPerformedUseAction = true;
    return false;
    //return ReturnValue;    
}

exec function PressedUseButton()
{
    Inputs.bPressedUseButton = true;
    bInvalidateReleasedUse = false;
    //return;    
}

exec function ReleasedUseButton()
{
    // End:0x2E
    if(__NFUN_129__(bInvalidateReleasedUse))
    {
        Inputs.bReleasedUseButton = true;
    }
    bInvalidateReleasedUse = false;
    //return;    
}

exec function ToggleNightVision()
{
    Inputs.bPressedToggleNightVision = true;
    //return;    
}

exec function ToggleCamcorder()
{
    Inputs.bPressedToggleCamcorder = true;
    //return;    
}

exec function ZoomIn()
{
    Inputs.bPressedZoomIn = true;
    //return;    
}

exec function ZoomOut()
{
    Inputs.bPressedZoomOut = true;
    //return;    
}

simulated exec function StartZoomIn()
{
    ZoomInput = 1;
    Inputs.bStartedActiveZoom = true;
    //return;    
}

simulated exec function StartZoomOut()
{
    ZoomInput = -1;
    Inputs.bStartedActiveZoom = true;
    //return;    
}

simulated exec function StopZoom()
{
    ZoomInput = 0;
    Inputs.bStartedActiveZoom = false;
    //return;    
}

exec function PressedReloadBatteries()
{
    Inputs.bPressedReloadBatteries = true;
    //return;    
}

exec function PressedJump()
{
    Inputs.bPressedJump = true;
    //return;    
}

exec function GammaCalibration()
{
    HUD.SetGammaCalibrationActive(__NFUN_129__(HUD.bGammaCalibrationOpen));
    FullScreenOverlayChanged();
    //return;    
}

exec function BehindView()
{
    // End:0x3F
    if(__NFUN_154__(int(WorldInfo.NetMode), int(NM_Standalone)))
    {
        SetBehindView(__NFUN_129__(bBehindView));
    }
    //return;    
}

function SetBehindView(bool bNewBehindView)
{
    bBehindView = bNewBehindView;
    // End:0x41
    if(__NFUN_114__(LocalPlayer(Player), none))
    {
        SetBehindView(bNewBehindView);
    }
    LastCameraTimeStamp = __NFUN_175__(WorldInfo.TimeSeconds, 1.0000000);
    //return;    
}

function bool UsingFirstPersonCamera()
{
    return __NFUN_129__(bBehindView);
    //return ReturnValue;    
}

function SetCameraMode(name NewCamMode)
{
    bDebugFreeCam = false;
    bDebugFixedCam = false;
    // End:0x9C
    if(__NFUN_254__(NewCamMode, 'FreeCam'))
    {
        // End:0x49
        if(__NFUN_129__(bBehindView))
        {
            SetBehindView(true);
        }
        bDebugFreeCam = true;
        DebugCamRot = CalcViewRotation;
        DebugCamRot.Roll = 0;
        DebugCamPos = CalcViewLocation;        
    }
    else
    {
        // End:0x102
        if(__NFUN_254__(NewCamMode, 'FixedCam'))
        {
            // End:0xCD
            if(__NFUN_129__(bBehindView))
            {
                SetBehindView(true);
            }
            bDebugFixedCam = true;
            DebugCamRot = CalcViewRotation;
            DebugCamPos = CalcViewLocation;            
        }
        else
        {
            // End:0x11A
            if(bBehindView)
            {
                SetBehindView(false);
            }
        }
    }
    //return;    
}

function SpawnCamera()
{
    local Actor OldViewTarget;

    PlayerCamera = Spawn(MatineeCameraClass, self);
    // End:0x92
    if(__NFUN_119__(PlayerCamera, none))
    {
        OldViewTarget = ViewTarget;
        PlayerCamera.InitializeFor(self);
        PlayerCamera.SetViewTarget(OldViewTarget);        
    }
    //return;    
}

event float GetFOVAngle()
{
    local CameraActor CamActor;

    CamActor = CameraActor(ViewTarget);
    // End:0x4A
    if(__NFUN_119__(CamActor, none))
    {
        return CamActor.FOVAngle;
    }
    return FOVAngle;
    //return ReturnValue;    
}

simulated event GetPlayerViewPoint(out Vector POVLocation, out Rotator POVRotation)
{
    // End:0x45
    if(__NFUN_132__(bDebugFreeCam, bDebugFixedCam))
    {
        POVRotation = DebugCamRot;
        POVLocation = DebugCamPos;        
    }
    else
    {
        // End:0x9F
        if(__NFUN_119__(CameraActor(ViewTarget), none))
        {
            // End:0x80
            if(__NFUN_114__(PlayerCamera, none))
            {
                ResetCameraMode();
                SpawnCamera();
            }
            super(PlayerController).GetPlayerViewPoint(POVLocation, POVRotation);            
        }
        else
        {
            // End:0xD1
            if(__NFUN_119__(PlayerCamera, none))
            {
                PlayerCamera.__NFUN_279__();
                PlayerCamera = none;
            }
            // End:0x11D
            if(__NFUN_119__(HeroPawn, none))
            {
                HeroPawn.GetCamera(POVLocation, POVRotation, FOVAngle);                
            }
            else
            {
                POVRotation = Rotation;
                POVLocation = Location;
            }
        }
    }
    CalcViewActor = ViewTarget;
    CalcViewActorLocation = ViewTarget.Location;
    CalcViewActorRotation = ViewTarget.Rotation;
    CalcViewLocation = POVLocation;
    CalcViewRotation = POVRotation;
    //return;    
}

function SetCinematicMode(SeqAct_ToggleCinematicMode Action, bool bInCinematicMode, bool bHidePlayer, bool bAffectsHUD, bool bAffectsMovement, bool bAffectsTurning, bool bAffectsButtons)
{
    super(PlayerController).SetCinematicMode(Action, bInCinematicMode, bHidePlayer, bAffectsHUD, bAffectsMovement, bAffectsTurning, bAffectsButtons);
    // End:0x76
    if(__NFUN_129__(bInCinematicMode))
    {
        bIgnoreMoveInput = 0;
        bIgnoreLookInput = 0;
    }
    // End:0xF6
    if(__NFUN_130__(__NFUN_119__(Action, none), __NFUN_119__(HeroPawn, none)))
    {
        // End:0xCE
        if(bInCinematicMode)
        {
            HeroPawn.EnterCinematicMode(Action);            
        }
        else
        {
            HeroPawn.ExitCinematicMode(Action);
        }
    }
    //return;    
}

reliable client simulated event ClientSetCameraFade(bool _enableFading, optional Color _FadeColor, optional Vector2D _FadeAlpha, optional float _FadeTime, optional bool _fadeAudio)
{
    bEnableFading = _enableFading;
    FadeColor = _FadeColor;
    // End:0xB0
    if(_enableFading)
    {
        FadeAlpha = _FadeAlpha;
        FadeTime = _FadeTime;
        FadeTimeRemaining = _FadeTime;
        bFadeAudio = _fadeAudio;
        FadeAmount = _FadeAlpha.X;        
    }
    else
    {
        FadeAmount = _FadeAlpha.Y;
    }
    //return;    
}

event OnSetMesh(SeqAct_SetMesh Action)
{
    // End:0x109
    if(__NFUN_154__(int(Action.MeshType), int(1)))
    {
        // End:0x109
        if(__NFUN_130__(__NFUN_130__(__NFUN_119__(HeroPawn, none), __NFUN_119__(Action.NewSkeletalMesh, none)), __NFUN_119__(Action.NewSkeletalMesh, HeroPawn.Mesh.SkeletalMesh)))
        {
            HeroPawn.Mesh.SetSkeletalMesh(Action.NewSkeletalMesh);
        }
    }
    //return;    
}

reliable client simulated function ClientSetHUD(Class<HUD> newHUDType)
{
    super(PlayerController).ClientSetHUD(newHUDType);
    HUD = OLHUD(myHUD);
    //return;    
}

event ForcePause(bool bPause)
{
    SetPause(bPause);
    // End:0x54
    if(__NFUN_130__(bPause, __NFUN_119__(HUD, none)))
    {
        HUD.bLostFocusPaused = false;
    }
    //return;    
}

event FullScreenOverlayChanged()
{
    // End:0xD2
    if(__NFUN_130__(__NFUN_119__(HUD, none), __NFUN_132__(__NFUN_132__(HUD.bGammaCalibrationOpen, HUD.bGameOver), __NFUN_130__(HUD.bSplashScreenOpen, ActiveSplashScreen.bPauseGame))))
    {
        // End:0xCF
        if(__NFUN_129__(HUD.bGameOver))
        {
            SetPause(true);
        }        
    }
    else
    {
        SetPause(false);
    }
    //return;    
}

function DrawHUD(HUD H)
{
    local OLHUD OLHUD;

    super(PlayerController).DrawHUD(H);
    OLHUD = OLHUD(H);
    OLHUD.Draw();
    //return;    
}

simulated function DisplayDebug(HUD H, out float out_YL, out float out_YPos)
{
    local OLGame CurrentGame;

    H.Canvas.SetDrawColor(255, 255, 200);
    H.Canvas.SetPos(4.0000000, out_YPos);
    CurrentGame = OLGame(WorldInfo.Game);
    // End:0x1DD
    if(__NFUN_255__(CurrentGame.CurrentCheckpointName, 'None'))
    {
        // End:0x172
        if(CurrentGame.bIsPlayingDLC)
        {
            H.Canvas.DrawText(__NFUN_112__(__NFUN_112__("Checkpoint: ", string(CurrentGame.CurrentCheckpointName)), " [dlc]"));            
        }
        else
        {
            H.Canvas.DrawText(__NFUN_112__("Checkpoint: ", string(CurrentGame.CurrentCheckpointName)));
        }        
    }
    else
    {
        H.Canvas.DrawText("Checkpoint: [none]");
    }
    __NFUN_184__(out_YPos, out_YL);
    // End:0x356
    if(__NFUN_132__(bDebugFreeCam, bDebugFixedCam))
    {
        H.Canvas.SetDrawColor(255, 255, 200);
        H.Canvas.SetPos(4.0000000, out_YPos);
        H.Canvas.DrawText(__NFUN_112__(__NFUN_112__(__NFUN_112__("Camera pos: ", string(DebugCamPos)), ", rot: "), string(DebugCamRot)));
        __NFUN_184__(out_YPos, out_YL);
    }
    // End:0x4B0
    if(IsPaused())
    {
        H.Canvas.SetDrawColor(240, 20, 20);
        H.Canvas.SetPos(__NFUN_171__(0.8000000, HUD.Canvas.ClipX), 20.0000000);
        // End:0x470
        if(bDebugFreeCam)
        {
            H.Canvas.DrawText("PAUSED - FREE CAMERA");            
        }
        else
        {
            H.Canvas.DrawText("PAUSED");
        }
    }
    //return;    
}

// Export UOLPlayerController::execStopAllSounds(FFrame&, void* const)
native function StopAllSounds();

function OnOverrideAIMusic(OLSeqAct_OverrideAIMusic Action)
{
    // End:0x96
    if(Action.InputLinks[0].bHasImpulse)
    {
        bOverriddenMusic = true;
        OverriddenMusicState = Action.MusicState;
        OverriddenMusicDistance = Action.MusicDistance;        
    }
    else
    {
        // End:0xD9
        if(Action.InputLinks[1].bHasImpulse)
        {
            bOverriddenMusic = false;
        }
    }
    //return;    
}

// Export UOLPlayerController::execSavePersistentState(FFrame&, void* const)
native function SavePersistentState();

// Export UOLPlayerController::execNativeCreateCheckpointRecord(FFrame&, void* const)
native function NativeCreateCheckpointRecord(out CheckpointRecord Record);

// Export UOLPlayerController::execNativeApplyCheckpointRecord(FFrame&, void* const)
native function NativeApplyCheckpointRecord(const out CheckpointRecord Record);

function CreateCheckpointRecord(out CheckpointRecord Record)
{
    NativeCreateCheckpointRecord(Record);
    //return;    
}

function ApplyCheckpointRecord(const out CheckpointRecord Record)
{
    NativeApplyCheckpointRecord(Record);
    // End:0x46
    if(__NFUN_119__(HeroPawn, none))
    {
        HeroPawn.LifeSpan = 0.1000000;
    }
    UnPossess();
    WorldInfo.Game.RestartPlayer(self);
    //return;    
}

function ApplyDeprecatedCheckpointRecord(const out DeprecatedCheckpointRecord OldRecord)
{
    local OLGame CurrentGame;
    local CheckpointRecord NewRecord;

    NewRecord.NumBatteries = OldRecord.NumBatteries;
    NewRecord.CurrentObjective = OldRecord.CurrentObjective;
    NewRecord.CompletedObjectives = OldRecord.CompletedObjectives;
    NewRecord.CompletedRecordingMoments = OldRecord.CompletedRecordingMoments;
    NewRecord.UnreadRecordingMoments = OldRecord.UnreadRecordingMoments;
    NewRecord.ActivatedGameState = OldRecord.ActivatedGameState;
    NewRecord.CollectedDocuments = OldRecord.CollectedDocuments;
    NewRecord.UnreadDocuments = OldRecord.UnreadDocuments;
    NewRecord.CollectedBatteries = OldRecord.CollectedBatteries;
    NewRecord.bBatteryTutorialComplete = OldRecord.bBatteryTutorialComplete;
    NewRecord.bClimbUpTutorialComplete = OldRecord.bClimbUpTutorialComplete;
    NewRecord.bDocumentTutorialComplete = OldRecord.bDocumentTutorialComplete;
    NewRecord.bFoundBySoldierWhileHidden = OldRecord.bFoundBySoldierWhileHidden;
    NewRecord.bFoundBySurgeonWhileHidden = OldRecord.bFoundBySurgeonWhileHidden;
    NewRecord.RecordingTimeSeconds = OldRecord.RecordingTimeSeconds;
    NewRecord.CheckpointRecordVersion = 2;
    NewRecord.BatteryEnergy = 1.0000000;
    CurrentGame = OLGame(WorldInfo.Game);
    // End:0x44D
    if(__NFUN_130__(__NFUN_119__(CurrentGame, none), __NFUN_155__(int(CurrentGame.DifficultyMode), int(3))))
    {
        NewRecord.DifficultyMode = int(CurrentGame.DifficultyMode);        
    }
    else
    {
        NewRecord.DifficultyMode = 0;
    }
    ApplyCheckpointRecord(NewRecord);
    //return;    
}

event StartNewGameAtCheckpoint(string CheckpointStr, bool bSaveToDisk)
{
    local OLCheckpoint CheckCP, startCP;
    local OLHero Hero;
    local OLGame CurrentGame;
    local OLEngine Engine;

    // End:0x62
    foreach __NFUN_304__(Class'OLGame.OLCheckpoint', CheckCP)
    {
        // End:0x61
        if(__NFUN_122__(__NFUN_235__(string(CheckCP.CheckpointName)), __NFUN_235__(CheckpointStr)))
        {
            startCP = CheckCP;
            // End:0x62
            break;
        }        
    }    
    // End:0x256
    if(__NFUN_119__(startCP, none))
    {
        // End:0x9E
        if(HUD.IsMainMenuOpen())
        {
            StopAllSounds();
        }
        HUD.HideMenu();
        Hero = HeroPawn;
        UnPossess();
        // End:0x101
        if(__NFUN_119__(Hero, none))
        {
            Hero.__NFUN_279__();
        }
        ClearAllProgress();
        Engine = OLEngine(Class'Engine.Engine'.static.GetEngine());
        CurrentGame = OLGame(WorldInfo.Game);
        // End:0x256
        if(__NFUN_119__(CurrentGame, none))
        {
            // End:0x1F9
            if(__NFUN_130__(__NFUN_119__(Engine, none), __NFUN_129__(Engine.UsingFixedSaveLocation())))
            {
                Engine.SaveCheckpoint(startCP.CheckpointName, bSaveToDisk);
            }
            CurrentGame.CurrentCheckpointName = startCP.CheckpointName;
            CurrentGame.RestartPlayer(self);
        }
    }
    //return;    
}

reliable client simulated event ClientCommitMapChange()
{
    // End:0x2E
    if(__NFUN_119__(SoundEnvManager, none))
    {
        SoundEnvManager.ExitAllTouchingVolumes();
    }
    ShowLoadingOverlay();
    super(PlayerController).ClientCommitMapChange();
    HideLoadingOverlay();
    //return;    
}

// Export UOLPlayerController::execSaveBeforeQuitting(FFrame&, void* const)
native function SaveBeforeQuitting();

// Export UOLPlayerController::execClearAllProgress(FFrame&, void* const)
native function ClearAllProgress();

// Export UOLPlayerController::execShippingCheat_GiveAllCheckpoints(FFrame&, void* const)
native function bool ShippingCheat_GiveAllCheckpoints();

protected simulated function RegisterCustomPlayerDataStores()
{
    local LocalPlayer LP;

    LP = LocalPlayer(Player);
    super(PlayerController).RegisterCustomPlayerDataStores();
    // End:0x7B
    if(__NFUN_119__(LP, none))
    {
        ProfileSettings = OLProfileSettings(OnlinePlayerData.ProfileProvider.Profile);
    }
    //return;    
}

simulated function UnregisterPlayerDataStores()
{
    local LocalPlayer LP;

    LP = LocalPlayer(Player);
    // End:0x36
    if(__NFUN_119__(LP, none))
    {
        ProfileSettings = none;
    }
    super(PlayerController).UnregisterPlayerDataStores();
    //return;    
}

private final event SaveProfile()
{
    local int ControllerId;

    ControllerId = LocalPlayer(Player).ControllerId;
    // End:0xD3
    if(__NFUN_130__(__NFUN_119__(OnlineSub, none), NotEqual_InterfaceInterface(OnlineSub.PlayerInterface, OnlinePlayerInterface(none))))
    {
        // End:0xD3
        if(__NFUN_155__(ControllerId, -1))
        {
            OnlineSub.PlayerInterface.WriteProfileSettings(byte(ControllerId), ProfileSettings);
        }
    }
    //return;    
}

function ClearSaveProfileDelegate(int ControllerId, delegate<OnWriteProfileSettingsComplete> WriteProfileSettingsCompleteDelegate)
{
    local OnlinePlayerInterface PlayerInt;

    // End:0xAD
    if(WriteProfileSettingsCompleteDelegate != none)
    {
        // End:0xAD
        if(__NFUN_119__(OnlineSub, none))
        {
            PlayerInt = OnlineSub.PlayerInterface;
            // End:0xAD
            if(NotEqual_InterfaceInterface(PlayerInt, OnlinePlayerInterface(none)))
            {
                // End:0xAD
                if(__NFUN_155__(ControllerId, -1))
                {
                    PlayerInt.ClearWriteProfileSettingsCompleteDelegate(byte(ControllerId), WriteProfileSettingsCompleteDelegate);
                }
            }
        }
    }
    //return;    
}

function OnProfileWriteComplete(byte LocalUserNum, bool bWasSuccessful)
{
    ClearSaveProfileDelegate(int(LocalUserNum), OnProfileWriteComplete);
    //return;    
}

reliable client simulated function ClientSaveAllPlayerData(optional bool bShouldForce, optional bool bSkipCacheUpdate)
{
    local LocalPlayer LP;

    LP = LocalPlayer(Player);
    // End:0x37
    if(__NFUN_119__(LP, none))
    {
        SaveProfile();
    }
    // End:0x65
    if(__NFUN_129__(bSkipCacheUpdate))
    {
        UpdateLocalCacheOfProfileSettings(ProfileSettings);
        bProfileSettingsUpdated = false;
    }
    //return;    
}

event UpdateLocalCacheOfProfileSettings(OLProfileSettings EffectiveProfileSettings)
{
    local float FloatValue;
    local int IntValue;
    local OLEngine TheEngine;

    // End:0x45B
    if(__NFUN_119__(EffectiveProfileSettings, none))
    {
        // End:0xC7
        if(__NFUN_119__(PlayerInput, none))
        {
            EffectiveProfileSettings.GetProfileSettingValueId(2, IntValue);
            PlayerInput.bInvertMouse = __NFUN_154__(IntValue, 1);
            EffectiveProfileSettings.GetProfileSettingValueFloat(13, FloatValue);
            PlayerInput.MouseSensitivity = FloatValue;
        }
        EffectiveProfileSettings.GetProfileSettingValueFloat(28, FloatValue);
        SetGamma(FloatValue);
        EffectiveProfileSettings.GetProfileSettingValueFloat(57, FloatValue);
        SetVolume(FloatValue);
        // End:0x255
        if(__NFUN_119__(HUD, none))
        {
            EffectiveProfileSettings.GetProfileSettingValueId(58, IntValue);
            HUD.bShowSubtitles = __NFUN_154__(IntValue, 1);
            EffectiveProfileSettings.GetProfileSettingValueId(60, IntValue);
            HUD.bShowCrosshair = __NFUN_154__(IntValue, 1);
            EffectiveProfileSettings.GetProfileSettingValueId(64, IntValue);
            HUD.bAlwaysShowPrompts = __NFUN_154__(IntValue, 1);
        }
        EffectiveProfileSettings.GetProfileSettingValueId(59, IntValue);
        TutorialManager.bTutorialsEnabled = __NFUN_154__(IntValue, 1);
        // End:0x2DD
        if(Class'OLGame.OLUtils'.static.IsConsole())
        {
            bToggleCrouch = true;            
        }
        else
        {
            EffectiveProfileSettings.GetProfileSettingValueId(63, IntValue);
            bToggleCrouch = __NFUN_154__(IntValue, 1);
        }
        // End:0x3CA
        if(__NFUN_119__(ForceFeedbackManager, none))
        {
            // End:0x374
            if(Class'OLGame.OLUtils'.static.IsConsole())
            {
                ForceFeedbackManager.bAllowsForceFeedback = true;                
            }
            else
            {
                EffectiveProfileSettings.GetProfileSettingValueId(1, IntValue);
                ForceFeedbackManager.bAllowsForceFeedback = __NFUN_154__(IntValue, 1);
            }
        }
        TheEngine = OLEngine(Class'Engine.Engine'.static.GetEngine());
        // End:0x45B
        if(__NFUN_119__(TheEngine, none))
        {
            TheEngine.ApplySystemSettings(EffectiveProfileSettings);
            TheEngine.ApplyKeyBindings(EffectiveProfileSettings);
        }
    }
    //return;    
}

event CheckForProfileUpdate()
{
    // End:0x64
    if(__NFUN_130__(__NFUN_130__(bProfileSettingsUpdated, __NFUN_119__(ProfileSettings, none)), __NFUN_151__(ProfileSettings.ProfileSettings.Length, 0)))
    {
        UpdateLocalCacheOfProfileSettings(ProfileSettings);
        bProfileSettingsUpdated = false;
    }
    //return;    
}

function UpdateDifficultyBasedValues()
{
    local OLGame TheGame;

    TheGame = OLGame(WorldInfo.Game);
    // End:0x81
    if(__NFUN_132__(__NFUN_114__(TheGame, none), __NFUN_154__(int(TheGame.DifficultyMode), int(0))))
    {
        MaxNumBatteries = NrmMaxNumBatteries;        
    }
    else
    {
        // End:0xC0
        if(__NFUN_154__(int(TheGame.DifficultyMode), int(1)))
        {
            MaxNumBatteries = HardMaxNumBatteries;            
        }
        else
        {
            MaxNumBatteries = NightmareMaxNumBatteries;
        }
    }
    // End:0xFD
    if(__NFUN_151__(NumBatteries, MaxNumBatteries))
    {
        NumBatteries = MaxNumBatteries;
    }
    //return;    
}

function NotifyDifficultyChanged()
{
    local OLBot Bot;

    UpdateDifficultyBasedValues();
    // End:0x38
    if(__NFUN_119__(HeroPawn, none))
    {
        HeroPawn.UpdateDifficultyBasedValues();
    }
    // End:0xC5
    foreach WorldInfo.AllControllers(Class'OLGame.OLBot', Bot)
    {
        // End:0xC4
        if(__NFUN_119__(Bot.EnemyPawn, none))
        {
            Bot.EnemyPawn.UpdateDifficultyBasedValues();
        }        
    }    
    //return;    
}

event UnlockAchievement(OLPlayerController.EOutlastAchievement achievement)
{
    local int ControllerId;

    ControllerId = LocalPlayer(Player).ControllerId;
    // End:0xDE
    if(__NFUN_130__(__NFUN_130__(__NFUN_119__(OnlineSub, none), NotEqual_InterfaceInterface(OnlineSub.PlayerInterface, OnlinePlayerInterface(none))), __NFUN_155__(ControllerId, -1)))
    {
        // End:0xDE
        if(OnlineSub.PlayerInterface.UnlockAchievement(byte(ControllerId), int(achievement)))
        {            
        }
    }
    //return;    
}

state PlayerWalking
{
    ignores Bump, HearNoise, SeePlayer;

    function PlayerMove(float DeltaTime)
    {
        local Rotator DeltaRot, DummyViewRotation;

        // End:0x11
        if(__NFUN_114__(Pawn, none))
        {
            return;
        }
        // End:0x11E
        if(__NFUN_129__(HUD.ShowingFullScreenOverlay()))
        {
            NativePlayerMove(DeltaTime);
            // End:0x11E
            if(__NFUN_119__(PlayerCamera, none))
            {
                DummyViewRotation = Rotation;
                DeltaRot.Yaw = int(PlayerInput.aTurn);
                DeltaRot.Pitch = int(PlayerInput.aLookUp);
                PlayerCamera.ProcessViewRotation(DeltaTime, DummyViewRotation, DeltaRot);
            }
        }
        //return;        
    }
    stop;    
}

defaultproperties
{
    bHasCamcorder=true
    bEnableShadowOptimisation=true
    bEnableLightOptimisation=true
    NrmMaxNumBatteries=10
    HardMaxNumBatteries=5
    NightmareMaxNumBatteries=2
    DefaultNumBatteries=2
    LightBarColor=(R=0.4100000,G=0.6300000,B=0.2600000,A=1.0000000)
    Struggle=(StruggleAct=none,Enemy=none,RefLocation=(X=0.0000000,Y=0.0000000,Z=0.0000000),RefDirection=(X=0.0000000,Y=0.0000000,Z=0.0000000),Config=(InitIdleAnimEnemy="None",EntryAnimPlayer="None",EntryAnimEnemy="None",CycleAnimPlayer="None",CycleAnimEnemy="None",ExitAnimPlayer="None",ExitAnimEnemy="None",KilledAnimPlayer="None",KillAnimEnemy="None",EntryPlayerBlendInTime=0.2500000,ExitPlayerBlendOutTime=0.2500000,CycleTime=3.0000000,bNoFail=false,MinRate=0.2500000,MaxRateStart=1.0000000,MaxRateEnd=3.0000000,SuccessPctForMinRate=0.5000000,SuccessPctForMaxRate=1.0000000,HeroAnimSets=none),EnemyAnimNode=none,bActiveStrugging=false,bSucceeded=false,CycleStartedTime=0.0000000,NbShakes=0.0000000,CurrentInputDirection=StruggleInputDirection.SID_Undefined,TotalDeltas=0.0000000,LastMouseX=0.0000000,SmoothedDirection=0.0000000,SmoothedAnimPlayRate=0.0000000)
    StruggleInputThresholdForWin=50000.0000000
    StruggleShakesThresholdForWin=2.0000000
    StruggleInputThresholdForWinNoFail=15000.0000000
    StruggleShakesThresholdForWinNoFail=5.0000000
    AIChaseMusicTimeDelay=0.5000000
    MusicAIStateGroup="AI_State"
    MusicAIStateNone="Z_None"
    MusicAIStatePatrol="A_Patrol"
    MusicAIStateInvestigate="B_Investigate"
    MusicAIStateChase="C_Chase"
    LoadingStateGroup="Loading_State"
    LoadingStateOn="LOADING_MODE"
    LoadingStateOff="GAMEPLAY_MODE"
    AIDistanceRTPC="Soldier_distance"
    SndResetMixStates=AkEvent'General_Sound.MIX_STATES_RESET'
    FirstSoldierFindableCheckpoint="Sewer_start"
    FirstSurgeonFindableCheckpoint="Male_surgeon"
    MatineeCameraClass=Class'OLGame.OLCamera'
    DebugFreeCamSpeed=0.0040000
    DebugFreeCamFOV=90.0000000
    CameraClass=none
    FOVAngle=80.0000000
    DesiredFOV=80.0000000
    DefaultFOV=80.0000000
    CheatClass=Class'OLGame.OLCheatManager'
    InputClass=Class'OLGame.OLPlayerInput'
    // Reference: CylinderComponent'OLGame.Default__OLPlayerController.CollisionCylinder'
    // TemplateOwnerClass: none
    // TemplateOwnerName: 'CollisionCylinder'
    // Archetype: CylinderComponent'UDKBase.Default__UDKPlayerController.CollisionCylinder'
    begin object name="CollisionCylinder"
        ReplacementPrimitive=none
    end object
    CylinderComponent=CollisionCylinder
    ForceFeedbackManagerClassName="WinDrv.XnaForceFeedbackManager"
    Components[0]=CollisionCylinder
    Components[1]=CollisionCylinder
    CollisionComponent=CollisionCylinder
}