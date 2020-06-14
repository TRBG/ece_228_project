%% Preparing the data and direcory

% This script will read the images from the Natural Conservancy dataset and
% create and augmented dataset to combat the inbalance in the number of
% examples in each of the classes.

% The script reades the images from the subfolders (named fish_01 to
% fish_26 for the fish images and mask_01 to mask_26 for the mask images)
% these folders are in the subdirectory /data and each of the subfolders
% corresponds to one of the 23 classes.

% After augmentation the MATLAB script will create a subdirectory
% /augmented_data and store the augmented images (and corresponding masks)

% The augmentation is done by: X-Flipping, Y-Flipping, Rotation,
% Translation, and/or Brightness Adjustments.


clear all, close all, clc

data_path ='.\data';
augmanted_data_path = '.\augmented_data';

% data_path = 'D:\Phd\UCSD Related\Courses\ECE Courses\ECE 228\Project\Natural Database\data';
% augmanted_data_path = 'D:\Phd\UCSD Related\Courses\ECE Courses\ECE 228\Project\Natural Database\augmented_data';
% mkdir(augmanted_data_path);

% Get a list of all files and folders in this folder.
files = dir(data_path);
% Get a logical vector that tells which is a directory.
dirFlags = [files.isdir];
dirFlags(1:2) = 0;
% Extract only those that are directories.
subFolders = files(dirFlags);

% Print folder names to command window.
% for k = 1 : length(subFolders)
%   fprintf('Sub folder #%d = %s\n', k, subFolders(k).name);
% end

imgType = '.jpg';
maskType = '.jpg';


%% Types of Augmentation

% The probability and threshold for augmentation
THRESHOLD = 0.5;
prob = 0.3;
% 
rng(1); 

% Flipping across the x/y axis
XFLIP = 1; 
XFLIP_Rate = prob;

YFLIP = 1;
YFLIP_Rate = prob; 

% Rotation
ROTATION = 1;
ROTATION_Range = [-10, 10];
ROTATION_Rate = prob;
ROTATION_Type = 'crop';
ROTATION_Num = 1;

% Brightness
BRIGHTNESS = 1;
BRIGHTNESS_Rate = prob;
BRIGHTNESS_Range = [0.9, 1.1];

% Translation
Translation = 1;
Translation_Rate = prob;
Translation_XRange = [-0.1, 0.1];
Translation_YRange = [-0.1, 0.1];


%% Augmenting the data

for i = 1 : length(subFolders)/2
    
    % The directory of the original data (images and masks) for this class i
    imgs_directory = strcat(data_path,'\', subFolders(i).name);
    masks_directory = strcat(data_path,'\', subFolders(length(subFolders)/2 + i).name);
    
    fprintf('%s\n', subFolders(i).name);
%     fprintf('%s\n', masks_directory);
    
    % A sturucture of all the images and masks for the current class
    images_files_list = dir([imgs_directory, '\', '*', imgType]);
    masks_files_list = dir([masks_directory, '\', '*', maskType]);
    
    % Creating the directory of the augmented data for the current class
    aug_imgs_directory = strcat(augmanted_data_path,'\', subFolders(i).name);
    aug_masks_directory = strcat(augmanted_data_path,'\', subFolders(length(subFolders)/2 + i).name);
    mkdir(aug_imgs_directory);
    mkdir(aug_masks_directory);
    
    % Checking the number of examples in this class as a ratio to 686
    % Which is almost equal to the number of images in the class with the
    % highest number of examples
    factor_to_balanced = 686/length(images_files_list);
    
    % If the ratio is low (we are comparing the reciprocal in the if
    % statement below) we augment
    
    if factor_to_balanced > 1.25
        
        for j = 1 : length(images_files_list)
            
            image_name = strcat(images_files_list(j).folder,'\', images_files_list(j).name);
            mask_name = strcat(masks_files_list(j).folder,'\', masks_files_list(j).name);
            
            fish_img_name = images_files_list(j).name(1:end-4);
            fish_mask_name = masks_files_list(j).name(1:end-4);
            
            img = im2double(imread(image_name));
            mask = imread(mask_name);
            
            for k = 1: floor(factor_to_balanced)
                
                flag = 0;
                % X Flipping    
                    if XFLIP && rand <= XFLIP_Rate
                        img = fliplr(img);
                        mask = fliplr(mask);
                        flag = 1;
                    end
                
                % Y Flipping    
                    if YFLIP && rand <= YFLIP_Rate
                        img = flipud(img);
                        mask = flipud(mask);
                        flag = 1;
                    end
                
                % Rotation
                if ROTATION && rand <= ROTATION_Rate
                    angle = rand.*(ROTATION_Range(2)-ROTATION_Range(1))+ROTATION_Range(1);
                    img = imrotate(img, angle, ROTATION_Type);
                    mask = imrotate(mask, angle, ROTATION_Type) > THRESHOLD;
                    flag = 1;
                end
                

                % Brightness
                if BRIGHTNESS && rand <= BRIGHTNESS_Rate
                    B_factor = rand*(BRIGHTNESS_Range(2)-BRIGHTNESS_Range(1)) + BRIGHTNESS_Range(1);
                    img = img.*B_factor;
                    img(img > 1) = 1;
                    img(img < 0) = 0;
                    flag = 1;
                end


                % Translation
                if Translation && rand <= Translation_Rate
                    Tx_factor = rand*(Translation_XRange(2)-Translation_XRange(1)) + Translation_XRange(1);
                    Ty_factor = rand*(Translation_YRange(2)-Translation_YRange(1)) + Translation_YRange(1);
                    Tx = round(Tx_factor * size(img, 2));
                    Ty = round(Ty_factor * size(img, 1));
                    img = imtranslate(img, [Tx, Ty]);
                    mask = imtranslate(mask, [Tx, Ty]);
                    flag = 1;
                end
                
                % If augmentation was conducted based on a probability, we
                % store the image
                
                if flag == 1
                    image_name = strcat(aug_imgs_directory,'\', fish_img_name,'_', string(k), '.png') ;
                    mask_name = strcat(aug_masks_directory,'\', fish_mask_name,'_', string(k), '.png');

                    imwrite(img, image_name)
                    imwrite(mask, mask_name)
                end
                
            end
            
        end
        
    end

end