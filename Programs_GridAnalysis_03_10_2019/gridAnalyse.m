function gridAnalyse
dfltDir=pwd;
hzBoxes=100;
vrBoxes=100;
E1=3;
E2=1;
cd('SurfaceImages_Set1\');
lst=dir('*.tif');
for i=1:length(lst)
    mastImage=imread(lst(i).name);
    dum1=~(mastImage==116|mastImage==117|mastImage==118|mastImage==119|mastImage==120);
    dum2=bwareaopen(~dum1,100);
    binReturnImg=~dum2;
    mast3DMat{i}=mastImage;
    raw3DMat{i}=binReturnImg;
    [rw,cl]=find(raw3DMat{i}==1);
end
cd(dfltDir);
%% Computing Ratios
ctr=1;
for i=1:length(raw3DMat)
    currImg=raw3DMat{i};
    sz=size(currImg);
    xL=round(sz(1)/hzBoxes);
    yL=round(sz(2)/vrBoxes);
    xValues=1:xL:sz(1);
    yValues=1:yL:sz(2);
    rtioMat=ones(length(xValues),length(yValues));
    xBc=0;
    for xB=1:(length(xValues)-1)
        xBc=xBc+1;
        yBc=0;
        for yB=1:(length(yValues)-1)
            yBc=yBc+1;
            xWind=xValues(xB):xValues(xB+1);
            yWind=yValues(yB):xValues(yB+1);
            subImg=currImg(xWind,yWind);
            ph1s=sum(sum(subImg==1));
            ph2s=sum(sum(subImg==0));
            rtio=(ph1s*E1+ph2s*E2/(ph1s+ph2s));
            rtioMat(xBc,yBc)=rtio;
        end
    end
    rtio3DMat{i}=rtioMat;
end    
  %% For Display Img      

  hf1=figure;
    hf=figure;
  s1=subplot(1,2,1);
  s2=subplot(1,2,2);
  
  hscrollbar=uicontrol('style','slider','units','normalized','position',[0 0 1 .05],'callback',@hscroll_Callback);
  function hscroll_Callback(src,evt)
   layerNumber=round(get(src,'value')*length(rtio3DMat))
   if(layerNumber==0)
       layerNumber=1;
   end
  mstImg=mast3DMat{layerNumber};
  subplot(s1);
  imshow(mstImg); 
  currImg=raw3DMat{layerNumber};
  subplot(s2);
  imshow(currImg);  hold on;
    for row = 1 : xL : sz(1)
        line([1, sz(2)], [row, row], 'Color', 'r', 'LineWidth', 1);
    end
    for col = 1 : yL : sz(2)
        line([col, col], [1, sz(1)], 'Color', 'r', 'LineWidth', 1);
    end
    figure(hf1); 
    surf(rtio3DMat{layerNumber});
    view(0,-90);
    figure(hf1);
    label('all',strcat('Layer # ',num2str(layerNumber)),'','');
  end
end 
