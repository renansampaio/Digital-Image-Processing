close all; 
clear all; 
clc;

%----------------------------------------
%-------- Leitura da Imgagem ------------
%----------------------------------------

f = imread('coins17.jpeg');
%figure;imshow(f);


%----------------------------------------
%------ Variáveis do projeto ------------
%----------------------------------------

areasReferencias = [42693, 36755, 55110, 46187, 65016];
valoresReferencias = [0.05, 0.10, 0.25, 0.50, 1];
valorTotal = 0.0;
FinalImg = f;


%----------------------------------------
%---- Conversão para Escala de Cinza ----
%----------------------------------------

I = rgb2gray(f);
%figure;imshow(I);


%----------------------------------------
%---- Deteccção de bordas ---------------
%----------------------------------------

c = edge(I, 'canny',0.3);
%figure; imshow(c);       


%----------------------------------------
%--- Dilatação das Bordas detectadas ----
%----------------------------------------

se = strel('disk',2);     
I2 = imdilate(c,se); 
%figure, imshow(I2);       


%----------------------------------------
%----- Preenchimento dos buracos --------
%----------------------------------------

d2 = imfill(I2, 'holes');
%figure, imshow(d2);        


%----------------------------------------
%------- Divisão em labels --------------
%----------------------------------------

label = bwlabel(d2);
num_cc = max(max(label));

im = cell(1,num_cc);
contMoedas = 0;


%----------------------------------------
%---- Vetor de componentes conexas ------
%----------------------------------------

for i=1:num_cc,
    im{i} = (label == i);
end


%----------------------------------------
%----- Vetor de Áreas e Centroides ------
%----------------------------------------

for i=1:num_cc,
    stats = regionprops(im{i},'Area');
    if( stats.Area > 10000),  % Remove todas as componentes conexas com área menores que 10000 pixels
        contMoedas = contMoedas + 1;
        im2{contMoedas} = im{i};
        %figure, imshow(im{contMoedas});
        areas{contMoedas} = stats;
        areas{contMoedas} = areas{contMoedas}.Area;
        centroides{contMoedas} = regionprops(im2{contMoedas}, 'Centroid');
        centroides{contMoedas} = centroides{contMoedas}.Centroid;
    end
end


%----------------------------------------
%----- Cálculo do Valor total -----------
%----------------------------------------

for i=1:contMoedas,
    [~,Idx] = min(abs(areasReferencias - areas{i}));
    valores{i} = valoresReferencias(1,Idx);
    valorTotal = valorTotal + valoresReferencias(1,Idx);
end


%----------------------------------------
%---- Inserção dos valores na imagem ----
%----------------------------------------

for i=1:contMoedas,
    FinalImg = insertText(FinalImg,centroides{i}-50,num2str(valores{i},'%0.2f'),'FontSize',40,'BoxColor', 'black', 'TextColor', 'white');
end

str = num2str(valorTotal,'%0.2f');
s = strcat('Total = R$ ',str);

FinalImg = insertText(FinalImg,[500 1150],s,'FontSize',50,'BoxColor', 'black', 'TextColor', 'white');
FinalImg = insertText(FinalImg,[80 50],'Resultado Final','FontSize',50,'BoxColor', 'black', 'TextColor', 'yellow');
f = insertText(f,[80 50],'Imagem original','FontSize',50,'BoxColor', 'black', 'TextColor', 'yellow');


%----------------------------------------
%----- Impressão final da imagem --------
%----------------------------------------
figure;
imshowpair(f,FinalImg,'montage');

