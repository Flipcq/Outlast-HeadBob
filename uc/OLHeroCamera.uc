class OLHeroCamera extends Object
    native
    config(Game);

struct native CamView
{
    var Vector Loc;
    var float Yaw;
    var float Pitch;
    var float Roll;

    structdefaultproperties
    {
        Loc=(X=0.0000000,Y=0.0000000,Z=0.0000000)
        Yaw=0.0000000
        Pitch=0.0000000
        Roll=0.0000000
    }
};

struct native ViewLimits
{
    var float MinYaw;
    var float MaxYaw;
    var float MinPitch;
    var float MaxPitch;

    structdefaultproperties
    {
        MinYaw=0.0000000
        MaxYaw=0.0000000
        MinPitch=0.0000000
        MaxPitch=0.0000000
    }
};

struct native SmoothingData
{
    var bool bActive;
    var CamView ViewWS;
    var float StartTime;
    var float Duration;

    structdefaultproperties
    {
        bActive=false
        ViewWS=(Loc=(X=0.0000000,Y=0.0000000,Z=0.0000000),Yaw=0.0000000,Pitch=0.0000000,Roll=0.0000000)
        StartTime=0.0000000
        Duration=0.0000000
    }
};

struct native TargettedSmoothingData
{
    var bool bActive;
    var float TargetAngleWS;
    var float StartAngleWS;
    var float StartTime;
    var float Duration;

    structdefaultproperties
    {
        bActive=false
        TargetAngleWS=0.0000000
        StartAngleWS=0.0000000
        StartTime=0.0000000
        Duration=0.0000000
    }
};

struct native CameraWaveData
{
    var() float Amplitude;
    var() float Frequency;
    var() float StartPhase;

    structdefaultproperties
    {
        Amplitude=0.0000000
        Frequency=0.0000000
        StartPhase=0.0000000
    }
};

struct native CameraShakeData
{
    var() float Intensity;
    var() float Duration;
    var() float FadeInTime;
    var() float FadeOutTime;
    var() bool bPositionless;
    var() editinline CameraWaveData YawWaveA;
    var() editinline CameraWaveData YawWaveB;
    var() editinline CameraWaveData PitchWaveA;
    var() editinline CameraWaveData PitchWaveB;
    var() editinline CameraWaveData RollWaveA;
    var() editinline CameraWaveData RollWaveB;
    var transient bool bActive;
    var transient float StartedTime;
    var transient Vector SourceLocation;
    var transient float YawOffset;
    var transient float PitchOffset;
    var transient float RollOffset;

    structdefaultproperties
    {
        Intensity=1.0000000
        Duration=0.4000000
        FadeInTime=0.0000000
        FadeOutTime=0.2500000
        bPositionless=false
        YawWaveA=(Amplitude=4.0000000,Frequency=22.0000000,StartPhase=0.5000000)
        YawWaveB=(Amplitude=4.0000000,Frequency=122.0000000,StartPhase=0.0000000)
        PitchWaveA=(Amplitude=3.0000000,Frequency=37.0000000,StartPhase=0.3000000)
        PitchWaveB=(Amplitude=2.0000000,Frequency=90.0000000,StartPhase=0.0000000)
        RollWaveA=(Amplitude=2.0000000,Frequency=20.0000000,StartPhase=0.0000000)
        RollWaveB=(Amplitude=0.0000000,Frequency=0.0000000,StartPhase=0.0000000)
        bActive=false
        StartedTime=0.0000000
        SourceLocation=(X=0.0000000,Y=0.0000000,Z=0.0000000)
        YawOffset=0.0000000
        PitchOffset=0.0000000
        RollOffset=0.0000000
    }
};

var OLHero Hero;
var CamView ViewWS;
var CamView ViewCS;
var ViewLimits Limits;
var ViewLimits SoftLimits;
var float SoftZonePitch;
var float SoftZoneYaw;
var Rotator BaseRotation;
var Vector BaseLocation;
var SmoothingData BaseViewSmoothing;
var float InputYaw;
var float InputPitch;
var float NeckOffsetFwd;
var float NeckOffsetSide;
var float NeckOffsetBaseYaw;
var float LookBackRatio;
var float LeanPushingRatio;
var bool bActiveLookAt;
var bool bUserControlsPawnRotation;
var bool bLocalSpacePlayerControl;
var float PendingYawCorrection;
var TargettedSmoothingData TargettedYawSmoothing;
var CameraShakeData ShakeData;
var const CameraShakeData SmallLandingShakeData;
var ForceFeedbackWaveform CamShakeFFWaveform;
var config name CameraBoneName;
var config float ViewLimitsSoftZone;
var config float SoftZoneStiffness;

defaultproperties
{
    ShakeData=(Intensity=1.0000000,Duration=0.4000000,FadeInTime=0.0000000,FadeOutTime=0.2500000,bPositionless=false,YawWaveA=(Amplitude=4.0000000,Frequency=22.0000000,StartPhase=0.5000000),YawWaveB=(Amplitude=4.0000000,Frequency=122.0000000,StartPhase=0.0000000),PitchWaveA=(Amplitude=3.0000000,Frequency=37.0000000,StartPhase=0.3000000),PitchWaveB=(Amplitude=2.0000000,Frequency=90.0000000,StartPhase=0.0000000),RollWaveA=(Amplitude=2.0000000,Frequency=20.0000000,StartPhase=0.0000000),RollWaveB=(Amplitude=0.0000000,Frequency=0.0000000,StartPhase=0.0000000),bActive=false,StartedTime=0.0000000,SourceLocation=(X=0.0000000,Y=0.0000000,Z=0.0000000),YawOffset=0.0000000,PitchOffset=0.0000000,RollOffset=0.0000000)
    SmallLandingShakeData=(Intensity=0.5000000,Duration=0.2000000,FadeInTime=0.0000000,FadeOutTime=0.2000000,bPositionless=true,YawWaveA=(Amplitude=1.0000000,Frequency=27.0000000,StartPhase=0.0000000),YawWaveB=(Amplitude=0.0000000,Frequency=0.0000000,StartPhase=0.0000000),PitchWaveA=(Amplitude=3.0000000,Frequency=14.0000000,StartPhase=0.3000000),PitchWaveB=(Amplitude=2.0000000,Frequency=87.0000000,StartPhase=0.0000000),RollWaveA=(Amplitude=2.2500000,Frequency=24.0000000,StartPhase=0.0000000),RollWaveB=(Amplitude=0.0000000,Frequency=0.0000000,StartPhase=0.0000000),bActive=false,StartedTime=0.0000000,SourceLocation=(X=0.0000000,Y=0.0000000,Z=0.0000000),YawOffset=0.0000000,PitchOffset=0.0000000,RollOffset=0.0000000)
    // Reference: ForceFeedbackWaveform'OLGame.Default__OLHeroCamera.ForceFeedbackWaveform0'
    begin object name="ForceFeedbackWaveform0" class=Engine.ForceFeedbackWaveform
        Samples=/* Array type was not detected. */
    end object
    CamShakeFFWaveform=ForceFeedbackWaveform0
    CameraBoneName="Hero-Camera"
    ViewLimitsSoftZone=20.0000000
    SoftZoneStiffness=1000.0000000
}