<p align="center">
<b>
THESE FILES BELONG TO THE SUPPLEMENTARY MATERIAL PROVIDED WITH THE ICIP 2016 PAPER<br/><a href="http://arxiv.org/abs/1605.03498" target="_blank">Deep Neural Networks Under Stress</a>
</b>
<br/><br/>
You can find supplementary results and high resolution images on <a href="http://webia.lip6.fr/~carvalho/static/neural_networks_under_stress/" target="_blank">Micael Carvalho's webpage</a>.
</p>

---

Hello !

Thank you for downloading our stress framework.
Please feel free to contact us if you have any questions or comments : micael.carvalho[at]lip6.fr

Inside this folder we offer a simple implementation of a descriptor. Under the hood, our code uses the MatConvNet VGG-M implementation.

To run it, you simply have to open MATLAB and execute:
```matlab
describe(image_or_folder, output_folder);
```

Where image_or_folder is the full path to an image or the path to a folder containing images. output_folder is where you want to save the feature vectors (in the .mat format).