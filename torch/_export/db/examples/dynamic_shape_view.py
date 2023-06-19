import torch

from torch._export.db.case import export_case


@export_case(
    example_inputs=(torch.ones(10, 10),),
    tags={"torch.dynamic-shape"},
)
def dynamic_shape_view(x):
    """
    Dynamic shapes should be propagated to view arguments instead of being
    baked into the exported graph.
    """
    new_x_shape = x.size()[:-1] + (2, 5)
    x = x.view(*new_x_shape)
    return x.permute(0, 2, 1)
