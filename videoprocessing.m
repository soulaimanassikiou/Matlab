clc
close all;
clear;


 [file,path]=uigetfile({'*.jpg;*.png;*.mp4;'},'Choose a video');
 figure;

%  img = [path,file];
%  img = imread(img);
%  frameProcessing(img);
video =[path,file];
videoReader = VideoReader(video);
fps = get(videoReader, 'FrameRate');
disp(fps); % the fps is correct: it's the same declared in the video file properties
currAxes = axes;
i = 0;

while hasFrame(videoReader)
  vidFrame = readFrame(videoReader);
  %if i==0     
  subplot(1,2,1);
  imagesc(vidFrame);
  axis off;
  %end  
  %image(vidFrame, 'Parent', currAxes);
  %currAxes.Visible = 'off';
  pause(1/videoReader.FrameRate);
  i = i+1;
  if i==200 
      
      %imshow(vidFrame);
      frameProcessing(vidFrame);
      %i = 0;
  end
end