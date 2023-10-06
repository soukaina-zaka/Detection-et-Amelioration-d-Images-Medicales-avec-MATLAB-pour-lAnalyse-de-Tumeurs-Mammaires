%% Chargement de l'image
i = imread('C:\Users\hp\Desktop\New folder (3)\mdb1.pgn.png');
figure(1);
imshow(i);
title('Image originale');

% Si l'image est en couleur (RGB), convertissez-la en niveau de gris
try
    i = rgb2gray(i);
end

%% Recadrage du sein
z = im2bw(i, 0.1);
figure(2);
imshow(z);
title('Image en noir et blanc');

% R?cup?rer les propri?t?s de la r?gion (dans ce cas, les r?gions sont les tumeurs)
info = regionprops(z);
a = cat(1, info.Area);
[~, idx] = max(a);
X = info(idx).Centroid;
bw2 = bwselect(z, X(1), X(2), 8);
i = immultiply(i, bw2);
figure(3);
imshow(i);
title('Obtention du sein et du muscle');

%% Suppression de l'arri?re-plan noir
% Nous allons supprimer les coins noirs pour pouvoir s?lectionner le muscle
% en utilisant bwselect
% Convertir en noir et blanc une fois de plus
[x, y] = size(z);
tst = zeros(x, y);

% D?tecter les lignes vides
r1 = [];
m = 1;
for j = 1:x
    if isequal(z(j, :), tst(j, :))
        r1(m) = j;
        m = m + 1;
    end
end

% Suppression
i(:, r1) = [];
i(r1, :) = [];
figure(4);
imshow(i);
title('Apr?s la suppression de larri?re-plan');

%% Suppression du muscle
if i(1, 1) ~= 0
    c = 3;
    r = 3;
else
    r = 3;
    c = size(i, 2) - 3;
end

z2 = im2bw(i, 0.50);
bw3 = bwselect(z2, c, r, 8);
bw3 = ~bw3;
ratio = min(sum(bw3) / sum(z2));

if ratio >= 1
    i = immultiply(i, bw3);
else
    z2 = im2bw(i, 0.75);
    bw3 = bwselect(z2, c, r, 8);
    ratio2 = min(sum(bw3) / sum(z2));
    
    if round(ratio2) == 0
        lvl = graythresh(i);
        z2 = im2bw(i, 1.75 * lvl);
        bw3 = bwselect(z2, c, r, 8);
        bw3 = ~bw3;
        i = immultiply(i, bw3);
    else
        bw3 = ~bw3;
        i = immultiply(i, bw3);
    end
end

figure(5);
imshow(i);
title('Obtention seulement du sein');

%% Filtre Weiner
% Nous allons cr?er un masque de moyenne [3 3] avec SNR = 0,4
mask = fspecial('average', [3 3]);
SNR = 0.4;
i = deconvwnr(i, mask, SNR);
figure(6);
imshow(i);
title('Filtre Weiner');

%% Filtre Clahe
i = adapthisteq(i);
figure(7);
imshow(i);
title('Filtre Clahe');
