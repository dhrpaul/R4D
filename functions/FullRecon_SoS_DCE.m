function [MR,P]=FullRecon_SoS_DCE(P)
% DCE GOLDEN ANGLE RECONSTRUCTION
P=checkGAParams(P);

MR=GoldenAngle_Recon(strcat(P.folder,P.file)); %initialize MR object
%PARAMETERS
[MR,P] = UpdateReadParamsMR(MR,P);



%SENSITVITIES: IF USING SENSE MAPS; READ HERE
if P.sensitivitymaps == true
    if strcmp(P.sensitvitymapscalc,'sense')==1
            P.senseLargeOutput=1;
            run FullRecon_SoS_sense.m;
            sens=MR_sense.Sensitivity;
            clear MR_sense;
    end
end

%%%
MR.Perform1;                        %reading and sorting data
MR.CalculateAngles; 
MR.PhaseShift;
MR.Data=ifft(MR.Data,[],3);         %eventually: remove slice oversampling
[nx,ntviews,ny,nc]=size(MR.Data);

k=buildRadTraj2D(nx,ntviews,false,true,true,[],[],[],[],P.goldenangle);
% angles=[0:(P.goldenangle)*(pi/180):(ntviews-1)*(P.goldenangle)*(pi/180)]; %relative angles measured (first set at 0)

%%%SORTING
disp('Sorting data into timeframes...')
kdata=squeeze(MR.Data(:,:,:,:,1)); %select kdata for slice
% wfull=calcDCF(k,ImSize);              % not needed for BART??

nt=floor(ntviews/P.DCEparams.nspokes);              % calculate (max) number of frames
kdatac=kdata(:,1:nt*P.DCEparams.nspokes,:,:);       % crop the data according to the number of spokes per frame

for ii=1:nt                                         % sort the data into a time-series (maybe remove loop at later stage)
    kdatau(:,:,:,:,ii)=kdatac(:,(ii-1)*P.DCEparams.nspokes+1:ii*P.DCEparams.nspokes,:,:); %kdatau now (nfe nspoke nslice nc nt)
    ku(:,:,ii)=double(k(:,(ii-1)*P.DCEparams.nspokes+1:ii*P.DCEparams.nspokes));
%     anglesu(:,:,ii)=angles(1,(ii-1)*P.DCEparams.nspokes+1:ii*P.DCEparams.nspokes);
end

% wu=getRadWeightsGA(ku);

%% BART CS
%CHANGE TO CG MCNUFFT RECON?

res=MR.Parameter.Encoding.XRes(1);
pause(5);
coords=RadTraj2BartCoords(ku,res);
coordsfull=RadTraj2BartCoords(k,res);
%
reco_cs=zeros(res,res,length(P.reconslices),nt);
for slice=P.reconslices
    fprintf('Recon slice %d of %d.',slice,size(kdatau,3))
    ksp_acq=(kdatau(:,:,slice,:,:));
    ksp_acq_t=permute(ksp_acq,[3 1 2 4 6 7 8 9 10 11 5]);
    
    if strcmp(P.sensitvitymapscalc,'sense')==1
        sensbart=conj(sens(:,:,slice,:));
    elseif strcmp(P.sensitvitymapscalc,'espirit')==1
        if P.dynamicespirit==true
            nufft=bart('nufft -i -t',coords,ksp_acq_t);
            lowres_ksp=bart('fft -u 7',nufft);
            for t=1:size(ksp_acq_t,11)
                sensbart(:,:,:,:,t)=bart('ecalib -r15 -S -m1',lowres_ksp);
            end
            sensbart=permute(sensbart,[1 2 3 4 6 7 8 9 10 11 5]);
        else
            nufft=bart('nufft -i -t',coordsfull,permute(MR.Data(:,:,slice,:),[3 1 2 4]));
            lowres_ksp=bart('fft -u 7',nufft);
            sensoptions=['ecalib -r25 -S -m',num2str(P.espiritoptions.nmaps)]
            sensbart=bart(sensoptions,lowres_ksp);
        end
    else
        error('Error: sensitvity maps calculation unknown/not recognized')
    end
    
    bartoptions=['pics -S -d5 -RT:1024:0:',num2str(P.CS.reg), ' -i',num2str(P.CS.iter),' -t'];
    
    dummy=bart(bartoptions, coords, ksp_acq_t, sensbart);
    dummy=bart('rss 16',dummy);
    reco_cs(:,:,slice,:)=squeeze(dummy);

    if true
        cd(P.resultsfolder)
        voxelsize=MR.Parameter.Scan.AcqVoxelSize
        nii=make_nii(abs(permute(flip(squeeze(reco_cs),1),[2 1 3 4 5])),voxelsize,[],[],'');
        save_nii(nii,strcat(P.filename,'.nii'))

    end


end





disp('TO DO... REST OF DCE CODE AND MAKE INTERCOMPATIBLE WITH 4D')

end
