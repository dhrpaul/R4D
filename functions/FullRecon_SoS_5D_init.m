function [MR,P,ku,kdatau,k]=FullRecon_SoS_5D_init(P)
P=checkGAParams(P);
MR=GoldenAngle_Recon(strcat(P.folder,P.file)); %initialize MR object

%PARAMETERS
[MR,P] = UpdateReadParamsMR(MR,P);
MR.Parameter.Parameter2Read.echo=(P.TE-1)  %we do a loop over all echo times

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MR.Perform1;    %reading and sorting data
MR.CalculateAngles;
MR.PhaseShift;
MR.Data=ifft(MR.Data,[],3); %eventually: remove slice oversampling
[nx,ntviews,ny,nc]=size(MR.Data);
goldenangle=MR.Parameter.GetValue('`EX_ACQ_radial_golden_ang_angle');

if mod(P.TE,2)==0 %check if even 
    if  P.flyback==1 %check if there is flyback
        k=buildRadTraj2D(nx,ntviews,false,true,true,[],[],[],[],goldenangle);
        k=k(end:-1:1,:);
        disp('flyback correction!')
    end
else
    k=buildRadTraj2D(nx,ntviews,false,true,true,[],[],[],[],goldenangle);

end


%% do binning (for echo 1)
TR=MR.Parameter.Scan.TR;
halfscan=MR.Parameter.Scan.HalfScanFactors(2);
P.binparams.Fs=(size(MR.Data,3)*halfscan*TR*1e-3)^(-1); %!!!
P.binparams.goldenangle=MR.Parameter.GetValue('`EX_ACQ_radial_golden_ang_angle');

if P.TE==1
[kdatau,ku,P.gating_signal] = ksp2frames(MR.Data,k,P.binparams);
else
[kdatau,ku] = ksp2frames(MR.Data,k,P.binparams,P.gating_signal);
end

end
