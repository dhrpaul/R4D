classdef GoldenAngle_Recon < MRecon
    properties
        %none 
    end
    
    methods
        function MR = GoldenAngle_Recon( filename )
            MR=MR@MRecon(filename);
        end
        % Overload (overwrite) the existing Perform function of MRecon    
        function Perform( MR )
            MR.Perform1;    %reading and sorting data
            MR.CalculateAngles;
            MR.PhaseShift;
            MR.PerformGrid;
            MR.Perform2;
        end
        
        function Perform1( MR )            
            %Reconstruct only standard (imaging) data
            MR.Parameter.Parameter2Read.typ = 1;                        
            % Produce k-space Data (using MRecon functions)
            disp('Reading data...')
            MR.ReadData;
            disp('Corrections...')
            MR.DcOffsetCorrection;
            MR.PDACorrection;
            MR.RandomPhaseCorrection;
            MR.MeasPhaseCorrection;
            disp('Sorting data...')
            MR.SortData;
            disp('Perform part 1 finished')
        end
        function CalculateAngles(MR)
            disp('Calculating angles...')
            goldenangle=MR.Parameter.GetValue('`EX_ACQ_radial_golden_ang_angle');
            Npe=MR.Parameter.Scan.Samples(2); %number of phase-encoding lines
            angles=[0:(goldenangle)*(pi/180):(Npe-1)*(goldenangle)*(pi/180)]; %relative angles measured (first set at 0)
            MR.Parameter.Gridder.RadialAngles=angles';
        end
        
        function PhaseShift(MR)
            %Trajectory correction for free-breathing radial MRI 
            %Buonincontrini, Sawiak, Caprenter
            disp('Phase Shift (Eddy current) correction...')
            angles=MR.Parameter.Gridder.RadialAngles(1:size(MR.Data,2))'; %only use angles for which there is data
            anglesrad=mod(angles,2*pi);
            cksp=floor(size(MR.Data,1)/2)+1; %how to find it generally?
            
            for nc=1:size(MR.Data,4)
                for nz=floor(size(MR.Data,3)/2)+1;
                    y=unwrap(angle(MR.Data(cksp,:,nz,nc))); %phase of center of k-space (with corrected k: find closest to zero?!?!)
                    Gx=1;Gy=1;
                    x=[ones(size(anglesrad))',Gx.*cos(anglesrad'),Gy.*sin(anglesrad')];
                    beta=inv(x'*x)*x'*y';
                    phiec=(beta(2)*cos(angles)+beta(3)*sin(angles));
                    kspcorr(:,:,:,nc)=((MR.Data(:,:,:,nc))).*repmat(exp(-1i.*phiec),[size(MR.Data,1) 1 size(MR.Data,3)]);
                end
            end
            MR.Data=kspcorr;
        end
        
        
        function PerformGrid(MR)
            disp('Gridding data...')
            MR.GridderCalculateTrajectory;
            MR.Parameter.Gridder.AlternatingRadial='no';
            MR.GridData;
        end
        function Perform2(MR)
            %disp('Ringing Filter')
            %MR.RingingFilter;
            MR.ZeroFill
            disp('Converting to image space...')
%             MR.K2IM %if reconstructing slice by slice (yz) first iFFT in slice-direction
%             MR.EPIPhaseCorrection; %EPI correction for FOV/2 Ghost from eddy current effects
%             MR.K2IP;
            MR.K2I;
            disp('SENSE unfold...')
            MR.SENSEUnfold;
            MR.GridderNormalization;
            MR.ConcomitantFieldCorrection;
            disp('Combining Coils...')
            MR.CombineCoils;
            MR.Average;
            MR.GeometryCorrection;
            MR.RemoveOversampling;
            disp('Zerofilling...')
            MR.ZeroFill;
            MR.RotateImage;
            disp('Reconstruction finished')
        end

    end
    
    % These functions are Hidden to the user
    methods (Static, Hidden)

    end
end